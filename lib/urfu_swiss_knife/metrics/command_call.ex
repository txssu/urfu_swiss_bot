defmodule UrfuSwissKnife.Metrics.CommandCall do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :id, integer()
    field :command, String.t()
    field :by_user_id, integer()
    field :called_at, DateTime.t()
  end
end
