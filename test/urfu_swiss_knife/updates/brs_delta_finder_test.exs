defmodule UrFUSwissKnife.Updates.BRSDeltaFinderTest do
  use ExUnit.Case

  alias UrFUSwissKnife.Updates.BRSDeltaFinder

  describe "find_added/2" do
    test "returns added subjects" do
      subjects_was = [
        subject(1),
        subject(2)
      ]

      subjects_became = [
        subject(1),
        subject(2),
        subject(3)
      ]

      assert BRSDeltaFinder.find_added(subjects_was, subjects_became) == [subject(3)]
    end

    test "returns empty list if no subjects were added" do
      subjects_was = [
        subject(1),
        subject(2)
      ]

      subjects_became = [
        subject(1)
      ]

      assert BRSDeltaFinder.find_added(subjects_was, subjects_became) == []
    end

    test "returns empty list if both lists are empty" do
      assert BRSDeltaFinder.find_added([], []) == []
    end

    test "returns empty list if both lists are the same" do
      subjects = [
        subject(1),
        subject(2)
      ]

      assert BRSDeltaFinder.find_added(subjects, subjects) == []
    end
  end

  describe "find_deleted/2" do
    test "returns deleted subjects" do
      subjects_was = [
        subject(1),
        subject(2)
      ]

      subjects_became = [
        subject(1)
      ]

      assert BRSDeltaFinder.find_deleted(subjects_was, subjects_became) == [subject(2)]
    end

    test "returns empty list if no subjects were deleted" do
      subjects_was = [
        subject(1)
      ]

      subjects_became = [
        subject(1),
        subject(2)
      ]

      assert BRSDeltaFinder.find_deleted(subjects_was, subjects_became) == []
    end

    test "returns empty list if both lists are empty" do
      assert BRSDeltaFinder.find_deleted([], []) == []
    end

    test "returns empty list if both lists are the same" do
      subjects = [
        subject(1),
        subject(2)
      ]

      assert BRSDeltaFinder.find_deleted(subjects, subjects) == []
    end
  end

  describe "find_changed/2" do
    test "returns changed subjects" do
      subjects_was = [
        subject(1, 10),
        subject(2, 20)
      ]

      subjects_became = [
        subject(1, 20),
        subject(2, 20)
      ]

      assert BRSDeltaFinder.find_changed(subjects_was, subjects_became) == [
               {subject(1, 10), subject(1, 20)}
             ]
    end

    test "returns empty list if no subjects were changed" do
      subjects_was = [
        subject(1, 10),
        subject(2, 20)
      ]

      subjects_became = [
        subject(1, 10),
        subject(3, 30)
      ]

      assert BRSDeltaFinder.find_changed(subjects_was, subjects_became) == []
    end

    test "returns empty list if both lists are empty" do
      assert BRSDeltaFinder.find_changed([], []) == []
    end

    test "returns empty list if both lists are the same" do
      subjects = [
        subject(1, 10),
        subject(2, 20)
      ]

      assert BRSDeltaFinder.find_changed(subjects, subjects) == []
    end
  end

  defp subject(id, score \\ 0) do
    UrFUAPI.IStudent.BRS.Subject.new(id: id, score: score)
  end
end
