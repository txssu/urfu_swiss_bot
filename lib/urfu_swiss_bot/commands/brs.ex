defmodule UrFUSwissBot.Commands.BRS do
  @moduledoc false
  import ExGram.Dsl
  import UrFUSwissKnife.CharEscape

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.InlineKeyboardButton
  alias ExGram.Model.InlineKeyboardMarkup
  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.IStudent

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  defp menu_button_row do
    [%InlineKeyboardButton{text: "В меню", callback_data: "menu"}]
  end

  @spec handle({:callback_query, CallbackQuery.t()}, Cnt.t()) :: Cnt.t()
  def handle({:callback_query, %{data: "BRS"}}, context) do
    dbg(context.extra.user.default_brs_args)

    case context.extra.user.default_brs_args do
      nil -> ask_group(context)
      [group_id, year, semester] -> response_subjects(group_id, year, semester, context)
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
    [group_id, year_str, semester] = args = String.split(args, ",")
    year = String.to_integer(year_str)
    Accounts.set_user_default_brs_args(context.extra.user, args)

    response_subjects(group_id, year, semester, context)
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

  defp response_subjects(group_id, year, semester, context) do
    with {:ok, auth} <- IStudent.auth_user(context.extra.user),
         {:ok, subjects} <- IStudent.get_subjects(auth, group_id, year, semester) do
      response =
        Enum.map_join(subjects, "\n", fn subject ->
          title = escape_telegram_markdown(subject.title)
          score = subject.score |> to_string() |> escape_telegram_markdown()
          mark = format_mark(subject.summary_title)

          """
          *#{title}*
            Итог: #{score}
            Оценка: #{mark}
          """
        end)

      markup = [
        [%InlineKeyboardButton{text: "Обновить", callback_data: "BRS"}],
        [%InlineKeyboardButton{text: "Выбрать семестр", callback_data: "BRS.get_semester:#{group_id}"}],
        menu_button_row()
      ]

      context
      |> answer_callback(context.update.callback_query)
      |> edit(:inline, response,
        parse_mode: "MarkdownV2",
        reply_markup: %InlineKeyboardMarkup{inline_keyboard: markup}
      )
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

  defp format_mark(""), do: "отсутствует"
  defp format_mark(mark) when is_binary(mark), do: String.downcase(mark)
end
