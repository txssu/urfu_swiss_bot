defmodule UrFUSwissBot.Bot.BRS do
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery

  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUAPI.IStudent.BRS.SubjectScore

  alias UrFUSwissKnife.Accounts.User

  alias UrFUSwissBot.IStudent
  alias UrFUSwissBot.Utils

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  @keyboard (keyboard(:inline) do
               row do
                 button("В меню", callback_data: "menu")
               end
             end)

  @spec handle({:callback_query, CallbackQuery.t()}, Cnt.t()) :: Cnt.t()
  def handle({:callback_query, %{data: "brs"}}, context) do
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

  @spec format_subjects(Subject.t()) :: String.t()
  defp format_subjects(%Subject{name: name, total: total, grade: grade, scores: scores}) do
    name = Utils.escape_telegram_markdown(name)

    score =
      total
      |> Float.to_string()
      |> Utils.escape_telegram_markdown()

    grade = Utils.escape_telegram_markdown(grade)

    """
    *#{name}*
    *Итог:* #{score} \\- #{grade}
    """ <>
      Enum.map_join(scores, "\n", &format_subject_scores/1)
  end

  @spec format_subject_scores(SubjectScore.t()) :: String.t()
  defp format_subject_scores(%SubjectScore{
         name: name,
         raw: raw,
         multiplier: multiplier,
         total: total
       }) do
    Utils.escape_telegram_markdown("#{name} - #{raw} × #{multiplier} = #{total}")
  end
end
