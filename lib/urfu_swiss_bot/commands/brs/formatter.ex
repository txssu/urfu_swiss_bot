defmodule UrFUSwissBot.Commands.BRS.Formatter do
  @moduledoc false
  import UrFUSwissKnife.CharEscape

  alias UrFUAPI.IStudent.BRS.Subject

  require Logger

  @spec format_subject(Subject.t()) :: String.t()
  def format_subject(subject) do
    {title, score, mark} = format_subject_field(subject)

    """
    *#{title}*
      Итог: #{score}
      Оценка: #{mark}
    """
  end

  @spec format_subject_diff(Subject.t(), Subject.t()) :: String.t()
  def format_subject_diff(subject_was, subject_became) do
    {title, score_was, mark_was} = format_subject_field(subject_was)
    {_title, score_became, mark_became} = format_subject_field(subject_became)

    """
    *#{title}*
      Итог: #{score_was} → #{score_became}
      Оценка: #{mark_was} → #{mark_became}
    """
  end

  @spec average_score([Subject.t()]) :: String.t()
  def average_score(subjects) do
    {sum, count, zeros} =
      Enum.reduce(subjects, {0, 0, 0}, fn subject, {sum, count, zeros} ->
        zeros = if subject.score == 0, do: zeros + 1, else: zeros
        {sum + subject.score, count + 1, zeros}
      end)

    average_score = format_number(sum / count)

    cond do
      zeros == 0 ->
        "Средний балл: #{average_score}"

      zeros == count ->
        "Все оценки нулевые"

      true ->
        average_score_no_zeros = format_number(sum / (count - zeros))
        "Средний балл: #{average_score} \\(без нулей: #{average_score_no_zeros}\\)"
    end
  end

  defp format_subject_field(subject) do
    title = escape_telegram_markdown(subject.title)
    score = format_number(subject.score)
    mark = format_mark(subject.summary_title)

    {title, score, mark}
  end

  defp format_number(number) when is_integer(number) do
    number
    |> to_string()
    |> escape_telegram_markdown()
  end

  defp format_number(number) when is_float(number) do
    number
    |> Float.round(2)
    |> to_string()
    |> escape_telegram_markdown()
  end

  defp format_mark(mark) when mark in ["", nil], do: "отсутствует"
  defp format_mark(mark) when is_binary(mark), do: String.downcase(mark)

  defp format_mark(mark) do
    Logger.error(~s(Undefined formatting for mark "#{inspect(mark)}"))
  end
end
