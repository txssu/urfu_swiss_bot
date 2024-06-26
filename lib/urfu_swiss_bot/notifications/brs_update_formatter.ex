defmodule UrFUSwissBot.Notifications.BRSUpdateFormatter do
  @moduledoc false
  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUSwissBot.Commands.BRS.Formatter
  alias UrFUSwissKnife.CharEscape

  @spec format_update([Subject.t()], [Subject.t()], [Subject.t()]) :: String.t()
  def format_update(added_subjects, changed_subjects, deleted_subjects) do
    adds_section = format_added_subjects(added_subjects)
    changes_section = format_changed_subjects(changed_subjects)
    deletes_section = format_deleted_subjects(deleted_subjects)

    sections =
      [
        {"", changes_section},
        {"Новые предметы:\n", adds_section},
        {"Удалённые предметы:\n", deletes_section}
      ]
      |> Enum.reject(fn {_title, section} -> section == "" end)
      |> Enum.map_join("\n", fn {title, section} -> title <> section end)

    "Обновление баллов БРС\n#{sections}"
  end

  defp format_added_subjects(added_subjects) do
    Enum.map_join(added_subjects, "\n", &Formatter.format_subject/1)
  end

  defp format_deleted_subjects(deleted_subjects) do
    Enum.map_join(deleted_subjects, "\n", &CharEscape.escape_telegram_markdown(&1.title))
  end

  defp format_changed_subjects(changed_subjects) do
    Enum.map_join(changed_subjects, "\n", fn {subject_was, subject_became} ->
      Formatter.format_subject_diff(subject_was, subject_became)
    end)
  end
end
