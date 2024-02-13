defmodule UrfuSwissKnife.Feedback.Message do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :id, integer()
    field :from_id, integer()
    field :forwared_ids, [integer()]
    field :text, String.t(), default: ""
  end
end
