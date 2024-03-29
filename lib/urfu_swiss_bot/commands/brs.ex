defmodule UrfuSwissBot.Commands.Brs do
  @moduledoc false
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard
  import UrfuSwissKnife.CharEscape

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias UrfuApi.Istudent.Brs.Subject
  alias UrfuApi.Istudent.Brs.SubjectScore
  alias UrfuSwissKnife.Accounts.User
  alias UrfuSwissKnife.Istudent

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  @keyboard (keyboard(:inline) do
               row do
                 button("В меню", callback_data: "menu")
               end
             end)

  @spec handle({:callback_query, CallbackQuery.t()}, Cnt.t()) :: Cnt.t()
  def handle({:callback_query, %{data: "Brs"}}, context) do
    response = get_response(context.extra.user)

    edit(context, :inline, response, reply_markup: @keyboard, parse_mode: "MarkdownV2")
  end

  @spec get_response(User.t()) :: String.t()
  def get_response(user) do
    {:ok, auth} = Istudent.auth_user(user)

    auth
    |> Istudent.get_subjects()
    |> Enum.map_join("\n\n", &format_subjects/1)
  end

  @spec format_subjects(Subject.t()) :: String.t()
  defp format_subjects(%Subject{name: name, total: total, grade: grade, scores: scores}) do
    name = escape_telegram_markdown(name)

    score =
      total
      |> Float.to_string()
      |> escape_telegram_markdown()

    grade = escape_telegram_markdown(grade)

    """
    *#{name}*
    *Итог:* #{score} \\- #{grade}
    """ <>
      Enum.map_join(scores, "\n", &format_subject_scores/1)
  end

  @spec format_subject_scores(SubjectScore.t()) :: String.t()
  defp format_subject_scores(%SubjectScore{name: name, raw: raw, multiplier: multiplier, total: total}) do
    ~t"#{name} - #{raw} × #{multiplier} = #{total}"
  end
end
