defmodule UrFUSwissKnife.PersistentCache.CommunalCharges do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct strict: true do
    field :id, integer()
    field :debt, integer()
    field :contract, String.t()
  end
end
