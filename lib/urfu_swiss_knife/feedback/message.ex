defmodule UrFUSwissKnife.Feedback.Message do
  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :from_id, integer()
    field :forwared_ids, [integer()]
  end

  use ExConstructor
end
