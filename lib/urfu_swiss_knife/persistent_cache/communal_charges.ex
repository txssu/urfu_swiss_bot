defmodule UrFUSwissKnife.PersistentCache.CommunalCharges do
  use TypedStruct

  typedstruct strict: true do
    field :id, integer()
    field :debt, integer()
    field :contract, String.t()
  end

  use ExConstructor
end
