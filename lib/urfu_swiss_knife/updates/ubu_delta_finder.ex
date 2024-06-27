defmodule UrFUSwissKnife.Updates.UBUDeltaFinder do
  @moduledoc false

  @spec find_change(integer(), integer()) :: integer() | nil
  def find_change(debt_was, debt_became) do
    if debt_was != debt_became do
      debt_became
    end
  end
end
