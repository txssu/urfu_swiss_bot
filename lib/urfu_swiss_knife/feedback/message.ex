defmodule UrFUSwissKnife.Feedback.Message do
  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :from_id, integer()
    field :original_id, integer()
  end

  @spec new(integer(), integer(), integer()) :: t()
  def new(id, from_id, original_id) do
    %__MODULE__{id: id, from_id: from_id, original_id: original_id}
  end
end
