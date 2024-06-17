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

  defp format_subject_field(subject) do
    title = escape_telegram_markdown(subject.title)
    score = subject.score |> to_string() |> escape_telegram_markdown()
    mark = format_mark(subject.summary_title)

    {title, score, mark}
  end

  defp format_mark(mark) when mark in ["", nil], do: "отсутствует"
  defp format_mark(mark) when is_binary(mark), do: String.downcase(mark)

  defp format_mark(mark) do
    Logger.error(~s(Undefined formatting for mark "#{inspect(mark)}"))
  end
end
