defmodule UrFUSwissBot.Bot.BRS do
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard

  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUAPI.IStudent.BRS.SubjectScore

  alias UrFUSwissBot.Repo.User

  alias UrFUSwissBot.IStudent
  alias UrFUSwissBot.Utils

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  @keyboard (keyboard(:inline) do
               row do
                 button("В меню", callback_data: "menu")
               end
             end)

  def handle({:callback_query, %{data: "brs"}}, context) do
    response = get_response(context.extra.user)

    edit(context, :inline, response, reply_markup: @keyboard, parse_mode: "MarkdownV2")
  end

  def get_response(%User{username: username, password: password}) do
    {:ok, auth} = IStudent.auth(username, password)

    subjects = IStudent.get_subjects(auth)

    subjects
    |> Enum.map(&IStudent.preload_subject_scores(auth, &1))
    |> Enum.map_join("\n\n", &format_subjects/1)
  end

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

  defp format_subject_scores(%SubjectScore{
         name: name,
         raw: raw,
         multiplier: multiplier,
         total: total
       }) do
    Utils.escape_telegram_markdown("#{name} - #{raw} × #{multiplier} = #{total}")
  end
end
