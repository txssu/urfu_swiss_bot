defmodule UrFUSwissBot.IStudent.Models.Object do
  alias UrFUSwissBot.IStudent.Models.ObjectScore
  alias UrFUSwissBot.Utils

  defstruct ~w[id name score grade scores]a

  def new(fields) do
    struct!(__MODULE__, fields)
  end

  def to_string(%__MODULE__{name: name, score: score, grade: grade, scores: scores}) do
    name = Utils.escape_telegram_markdown(name)
    score = score |> Float.to_string() |> Utils.escape_telegram_markdown()
    grade = Utils.escape_telegram_markdown(grade)

    """
    *#{name}*
    *Итог:* #{score} \\- #{grade}
    """ <>
      Enum.map_join(scores, "\n", fn score ->
        score
        |> ObjectScore.to_string()
        |> Utils.escape_telegram_markdown()
      end)
  end
end
