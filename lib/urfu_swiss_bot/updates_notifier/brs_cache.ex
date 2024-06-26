defmodule UrFUSwissBot.UpdatesNotifier.BRSCache do
  @moduledoc false
  import ExGram.Dsl.Keyboard

  alias UrFUSwissBot.Commands.BRS.Formatter
  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.CharEscape

  require ExGram.Dsl.Keyboard

  @type subject_score() :: UrFUSwissKnife.PersistentCache.BRSCache.t()

  @spec update_brs(Accounts.User.t(), subject_score() | nil, subject_score()) :: :ok
  def update_brs(_user, nil, _became), do: :ok

  def update_brs(user, was, became) do
    was_subjects = was.subjects
    became_subjects = became.subjects

    diffs = find_diffs(was_subjects, became_subjects)
    {adds_section, changes_section, deletes_section} = format_diffs(diffs, was_subjects, became_subjects)

    formatted_sections =
      [
        {"", changes_section},
        {"Новые предметы:\n", adds_section},
        {"Удалённые предметы:\n", deletes_section}
      ]
      |> Enum.reject(fn {_title, section} -> section == "" end)
      |> Enum.map_join("\n", fn {title, section} -> title <> section end)

    if formatted_sections != "" do
      text = "Обновление баллов БРС\n#{formatted_sections}"

      ExGram.send_message!(user.id, text,
        reply_markup: brs_keyboard(),
        parse_mode: "MarkdownV2",
        bot: UrFUSwissBot.Bot
      )
    end

    :ok
  end

  defp brs_keyboard do
    keyboard(:inline) do
      row do
        button("Открыть БРС", url: "https://istudent.urfu.ru/s/servis-informirovaniya-studenta-o-ballah-brs")
      end
    end
  end

  defp find_diffs(subjects_was, subjects_became) do
    ids_was = MapSet.new(subjects_was, & &1.id)
    ids_became = MapSet.new(subjects_became, & &1.id)

    {find_adds(ids_was, ids_became), find_changes(subjects_was, subjects_became), find_deletes(ids_was, ids_became)}
  end

  defp find_deletes(ids_was, ids_became) do
    MapSet.difference(ids_was, ids_became)
  end

  defp find_adds(ids_was, ids_became) do
    MapSet.difference(ids_became, ids_was)
  end

  defp find_changes(subjects_was, subjects_became) do
    Enum.reduce(subjects_was, MapSet.new(), fn subject_was, result ->
      case get_subject_from_list(subjects_became, subject_was.id) do
        nil ->
          result

        subject_became when subject_was.score == subject_became.score ->
          result

        subject_became when subject_was.score != subject_became.score ->
          MapSet.put(result, {subject_was, subject_became})
      end
    end)
  end

  defp format_diffs({adds, changes, deletes}, was_subjects, became_subjects) do
    adds_section =
      Enum.map_join(adds, "\n", fn added_id ->
        became_subjects
        |> get_subject_from_list(added_id)
        |> Formatter.format_subject()
      end)

    changes_section =
      Enum.map_join(changes, "\n", fn {subject_was, subject_became} ->
        Formatter.format_subject_diff(subject_was, subject_became)
      end)

    deletes_section =
      Enum.map_join(deletes, "\n", fn deleted_id ->
        was_subjects
        |> get_subject_from_list(deleted_id)
        |> Map.fetch!(:title)
        |> CharEscape.escape_telegram_markdown()
      end)

    {adds_section, changes_section, deletes_section}
  end

  defp get_subject_from_list(subjects, id) do
    Enum.find(subjects, &(&1.id == id))
  end
end
