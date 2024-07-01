defmodule UrFUSwissBot.Commands.BRS.Formatter do
  @moduledoc false
  import UrFUSwissKnife.CharEscape

  alias UrFUAPI.IStudent.BRS.Attestation
  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUAPI.IStudent.BRS.SubjectEvent
  alias UrFUAPI.IStudent.BRS.SubjectInfo

  require Logger

  @spec format_subjects_with_info_command([Subject.t()], [String.t()]) :: String.t()
  def format_subjects_with_info_command(subjects, links) do
    subjects
    |> Enum.zip(links)
    |> Enum.map_join("\n", fn {subject, link} ->
      if numberic_id?(subject.id) do
        format_subject(subject)
      else
        format_subject_with_add_info_link(subject, link)
      end
    end)
  end

  @spec format_subject(Subject.t()) :: String.t()
  def format_subject(subject) do
    {title, score, mark} = format_subject_field(subject)

    indicator = if subject.score == 0, do: "🔴 ", else: "•"

    """
    *#{title}*
    #{indicator} #{score} / #{mark}
    """
  end

  @spec format_subject_with_add_info_link(Subject.t(), String.t()) :: String.t()
  def format_subject_with_add_info_link(subject, link) do
    format_subject(subject) <> ~t"/brsinfo_#{link}" <> "\n"
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

  @spec format_subject_info(SubjectInfo.t()) :: String.t()
  def format_subject_info(%SubjectInfo{} = subject_info) do
    ~i"""
    *#{subject_info.title}*
    Итог: #{subject_info.result.score} / #{subject_info.result.mark}

    """ <> format_subject_events(subject_info.events)
  end

  defp format_subject_events(events) do
    Enum.map_join(events, "\n", fn %SubjectEvent{} = event ->
      emoji = get_emoji_for_subject_type(event.type)
      title = String.capitalize(event.type_title)
      factor = format_factor(event.total_factor)

      ~i"#{emoji} *#{title}* — #{event.score_without_factor} × #{factor} \= #{event.score_with_factor}" <>
        format_attestations(event.attestations)
    end)
  end

  defp format_attestations(attestations) do
    not_zero_blocks = Enum.reject(attestations, &(&1.factor == 0))

    formatted_attestations =
      Enum.map_join(not_zero_blocks, "\n\n", fn %Attestation{} = attestation ->
        type = format_attestation_type(attestation.type)
        factor = format_factor(attestation.factor)

        if attestation.factor == 1 do
          format_controls(attestation.controls)
        else
          ~i"*#{type}* — #{attestation.score_without_factor} × #{factor} \= #{attestation.score_with_factor}" <>
            "\n" <> format_controls(attestation.controls)
        end
      end)

    result =
      case not_zero_blocks do
        [_attestation] -> formatted_attestations
        _otherwise -> "\n" <> formatted_attestations
      end

    "\n" <> result <> "\n"
  end

  defp format_controls(controls) do
    Enum.map_join(controls, "\n", fn %Attestation.Control{} = control ->
      ~i"• #{control.title} — #{control.score} из #{control.max_score}"
    end)
  end

  defp get_emoji_for_subject_type("practice"), do: "🔵"
  defp get_emoji_for_subject_type("lecture"), do: "🟢"
  defp get_emoji_for_subject_type("laboratory"), do: "🟠"
  defp get_emoji_for_subject_type(_other), do: "🟣"

  defp format_attestation_type("intermediate"), do: "Промежуточные"
  defp format_attestation_type("current"), do: "Текущие"
  defp format_attestation_type(other), do: other

  defp format_factor(number) when is_integer(number) do
    "#{number}.00"
  end

  defp format_factor(number) do
    :erlang.float_to_binary(number, decimals: 2)
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

  defp numberic_id?(id) do
    String.match?(id, ~r/^\d+$/)
  end
end
