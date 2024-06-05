defmodule UrFUSwissBot.Commands.BRS do
  @moduledoc false
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard
  import UrFUSwissKnife.CharEscape

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias UrFUAPI.IStudent.BRS.SubjectEvent
  alias UrFUAPI.IStudent.BRS.SubjectInfo
  alias UrFUAPI.IStudent.BRS.SubjectInfo.Result
  alias UrFUSwissKnife.Accounts.User
  alias UrFUSwissKnife.IStudent

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  @keyboard (keyboard(:inline) do
               row do
                 button("В меню", callback_data: "menu")
               end
             end)

  @spec handle({:callback_query, CallbackQuery.t()}, Cnt.t()) :: Cnt.t()
  def handle({:callback_query, %{data: "BRS"}}, context) do
    response = get_response(context.extra.user)

    edit(context, :inline, response, reply_markup: @keyboard, parse_mode: "MarkdownV2")
  end

  @spec get_response(User.t()) :: String.t()
  def get_response(user) do
    {:ok, auth} = IStudent.auth_user(user)

    auth
    |> IStudent.get_subjects()
    |> Enum.map_join("\n\n", &format_subjects/1)
  end

  @spec format_subjects(SubjectInfo.t()) :: String.t()
  defp format_subjects(%SubjectInfo{title: name, result: %Result{score: total, mark: grade}, events: events}) do
    name = escape_telegram_markdown(name)

    score =
      total
      |> to_string()
      |> escape_telegram_markdown()

    grade = escape_telegram_markdown(grade)

    """
    *#{name}*
    *Итог:* #{score} \\- #{grade}
    """ <>
      Enum.map_join(events, "\n", &format_subject_events/1)
  end

  @spec format_subject_events(SubjectEvent.t()) :: String.t()
  defp format_subject_events(%SubjectEvent{
         type_title: name,
         score_without_factor: raw,
         total_factor: multiplier,
         score_with_factor: total
       }) do
    name = name |> String.capitalize() |> escape_telegram_markdown()

    "  *#{name}*" <> ~t" - #{raw} × #{multiplier} = #{total}"
  end
end
