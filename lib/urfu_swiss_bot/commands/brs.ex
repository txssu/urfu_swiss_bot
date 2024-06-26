defmodule UrFUSwissBot.Commands.BRS do
  @moduledoc false
  import ExGram.Dsl
  import UrFUSwissBot.CommandsHelper

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.InlineKeyboardButton
  alias ExGram.Model.InlineKeyboardMarkup
  alias ExGram.Model.Message
  alias UrFUSwissBot.Commands.BRS.Formatter
  alias UrFUSwissKnife.BRSShortLink
  alias UrFUSwissKnife.IStudent

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  @expired_link_text """
  Ссылка устарела. Попробуйте обновить данные.
  """

  defp menu_button_row do
    [%InlineKeyboardButton{text: "В меню", callback_data: "Menu"}]
  end

  @spec handle(
          {:callback_query, CallbackQuery.t()}
          | {:command, atom(), Message.t()}
          | {:command, String.t(), Message.t()}
          | {:text, String.t(), Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle({:command, command, _message}, context) when is_atom(command), do: entry_point(context)
  def handle({:callback_query, %{data: "BRS"}}, context), do: entry_point(context)

  def handle({:command, "brsinfo_" <> id, _message}, context) do
    case UrFUSwissKnife.BRSShortLink.get_args(id) do
      {group_id, year, semester, subject_id} -> response_subject(context, group_id, year, semester, subject_id)
      _other -> answer(context, @expired_link_text)
    end
  end

  def handle({:callback_query, %{data: "BRS.get_group"}}, context) do
    ask_group(context)
  end

  def handle({:callback_query, %{data: "BRS.get_semester:" <> group_id}}, context) do
    with {:ok, auth} <- IStudent.auth_user(context.extra.user),
         {:ok, filters} <- IStudent.get_filters(auth) do
      buttons =
        filters.groups
        |> Enum.find(&(&1.group_id == group_id))
        |> Map.fetch!(:years)
        |> Enum.map(&format_year_data(group_id, &1))
        |> List.insert_at(0, [%InlineKeyboardButton{text: "Выбрать группу", callback_data: "BRS.get_group"}])
        |> List.insert_at(0, menu_button_row())
        |> Enum.reverse()

      edit(context, :inline, "Выберите семестр", reply_markup: %InlineKeyboardMarkup{inline_keyboard: buttons})
    end
  end

  def handle({:callback_query, %{data: "BRS.get_brs:" <> args}}, context) do
    [group_id, year_str, semester] = String.split(args, ",")
    year = String.to_integer(year_str)

    with {:ok, auth} <- IStudent.auth_user(context.extra.user) do
      response_subjects(auth, group_id, year, semester, context)
    end
  end

  defp entry_point(context) do
    with {:ok, auth} <- IStudent.auth_user(context.extra.user),
         {:ok, {group_id, year, semester}} <- IStudent.get_latest_filter(auth) do
      response_subjects(auth, group_id, year, semester, context)
    end
  end

  defp ask_group(context) do
    with {:ok, auth} <- IStudent.auth_user(context.extra.user),
         {:ok, filters} <- IStudent.get_filters(auth) do
      buttons =
        filters.groups
        |> Enum.map(fn group ->
          [%InlineKeyboardButton{text: group.group_title, callback_data: "BRS.get_semester:#{group.group_id}"}]
        end)
        |> List.insert_at(0, menu_button_row())
        |> Enum.reverse()

      edit(context, :inline, "Выберите группу", reply_markup: %InlineKeyboardMarkup{inline_keyboard: buttons})
    end
  end

  defp response_subjects(auth, group_id, year, semester, context) do
    with {:ok, subjects} <- IStudent.get_subjects(auth, group_id, year, semester) do
      short_links =
        Enum.map(subjects, fn subject ->
          BRSShortLink.get_link(context.extra.user.id, group_id, year, semester, subject.id)
        end)

      subjects_text = Formatter.format_subjects_with_info_command(subjects, short_links)
      average_score_text = Formatter.average_score(subjects)

      response = subjects_text <> "\n\n" <> average_score_text

      markup = [
        [%InlineKeyboardButton{text: "Обновить", callback_data: "BRS"}],
        [%InlineKeyboardButton{text: "Выбрать семестр", callback_data: "BRS.get_semester:#{group_id}"}],
        menu_button_row()
      ]

      context
      |> answer_callback(context.update.callback_query)
      |> reply(response,
        parse_mode: "MarkdownV2",
        reply_markup: %InlineKeyboardMarkup{inline_keyboard: markup}
      )
    end
  end

  defp response_subject(context, group_id, year, semester, subject_id) do
    with {:ok, auth} <- IStudent.auth_user(context.extra.user),
         {:ok, subject_info} <- IStudent.get_subject_info(auth, group_id, year, semester, subject_id) do
      if subject_info.id != nil do
        subject_info
        |> Formatter.format_subject_info()
        |> then(&answer(context, &1, parse_mode: "MarkdownV2"))
      else
        answer(context, @expired_link_text)
      end
    end
  end

  defp format_year_data(group_id, %{semesters: semesters, year: year}) do
    year_name = format_year(year)

    Enum.map(semesters, fn semester ->
      semester_name = semester_num_to_name(semester)

      %InlineKeyboardButton{
        text: "#{year_name} #{semester_name}",
        callback_data: "BRS.get_brs:#{group_id},#{year},#{semester}"
      }
    end)
  end

  defp semester_num_to_name(1), do: "осенний"
  defp semester_num_to_name(2), do: "весенний"

  defp format_year(year) do
    short_year = year - 2000
    "#{short_year}/#{short_year + 1}"
  end
end
