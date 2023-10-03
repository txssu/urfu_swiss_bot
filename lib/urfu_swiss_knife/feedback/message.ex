defmodule UrFUSwissKnife.Feedback.Message do
  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :from_id, integer()
    field :original_id, integer()
  end

  use ExConstructor
end
