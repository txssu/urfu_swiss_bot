defmodule UrFUSwissBot.Bot.BRS do
  alias UrFUSwissBot.Repo.User
  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUAPI.IStudent.BRS.SubjectScore

  alias UrFUSwissBot.IStudent
  alias UrFUSwissBot.Utils

  import ExGram.Dsl
  require ExGram.Dsl

  import ExGram.Dsl.Keyboard
  require ExGram.Dsl.Keyboard

  @keyboard (keyboard(:inline) do
               row do
                 button("В меню", callback_data: "menu")
               end
             end)

  def handle({:callback_query, %{data: "brs"}}, context) do
    response = get_response(context.extra.user)

    context
    |> edit(:inline, response, reply_markup: @keyboard, parse_mode: "MarkdownV2")
  end

  def get_response(%User{username: username, password: password}) do
    {:ok, auth} = IStudent.auth(username, password)

    objects =
      IStudent.get_subjects(auth)
      |> Enum.map(&IStudent.preload_subject_scores(auth, &1))

    Enum.map_join(objects, "\n\n", &format_subjects/1)
  end

  defp format_subjects(%Subject{name: name, total: total, grade: grade, scores: scores}) do
    name = Utils.escape_telegram_markdown(name)
    score = total |> Float.to_string() |> Utils.escape_telegram_markdown()
    grade = Utils.escape_telegram_markdown(grade)

    """
    *#{name}*
    *Итог:* #{score} \\- #{grade}
    """ <>
      Enum.map_join(scores, "\n", &format_subject_scores/1)
  end

  defp format_subject_scores(%SubjectScore{
         name: name,
         raw: raw,
         multiplier: multiplier,
         total: total
       }) do
    "#{name} - #{raw} × #{multiplier} = #{total}"
    |> Utils.escape_telegram_markdown()
  end
end
