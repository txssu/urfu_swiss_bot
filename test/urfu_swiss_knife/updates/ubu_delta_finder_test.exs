defmodule UrFUSwissKnife.Updates.UBUDeltaFinderTest do
  use ExUnit.Case

  alias UrFUSwissKnife.Updates.UBUDeltaFinder

  describe "find_change/2" do
    test "returns new debt if it changed" do
      assert UBUDeltaFinder.find_change(0, 100) == 100
    end

    test "returns nil if debt didn't change" do
      assert UBUDeltaFinder.find_change(100, 100) == nil
    end
  end
end
