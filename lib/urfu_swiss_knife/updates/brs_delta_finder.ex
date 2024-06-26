defmodule UrFUSwissKnife.Updates.BRSDeltaFinder do
  @moduledoc false
  alias UrFUAPI.IStudent.BRS.Subject

  @spec find_added([Subject.t()], [Subject.t()]) :: [Subject.t()]
  def find_added(subjects_was, subjects_became) do
    Enum.reject(subjects_became, fn subject_became ->
      find_same_subject(subjects_was, subject_became)
    end)
  end

  @spec find_deleted([Subject.t()], [Subject.t()]) :: [Subject.t()]
  def find_deleted(subjects_was, subjects_became) do
    find_added(subjects_became, subjects_was)
  end

  @spec find_changed([Subject.t()], [Subject.t()]) :: [{was :: Subject.t(), became :: Subject.t()}]
  def find_changed(subjects_was, subjects_became) do
    subjects_became
    |> Enum.map(fn %Subject{score: score_became} = subject_became ->
      with %Subject{score: score_was} = subject_was <- find_same_subject(subjects_was, subject_became) do
        if score_was == score_became, do: nil, else: {subject_was, subject_became}
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp find_same_subject(enum, %Subject{id: id}) do
    Enum.find(enum, fn %Subject{id: enum_subject_id} -> id == enum_subject_id end)
  end
end
