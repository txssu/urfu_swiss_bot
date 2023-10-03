defmodule UrFUSwissKnife.Feedback.Message do
  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :from_id, integer()
    field :forwared_ids, [integer()]
    field :text, String.t(), default: ""
  end

  use ExConstructor
end
