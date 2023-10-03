defmodule UrFUSwissKnife.Metrics.CommandCall do
  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :command, String.t()
    field :by_user_id, integer()
    field :called_at, DateTime.t()
  end

  use ExConstructor
end
