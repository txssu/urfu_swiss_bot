defmodule UrFUSwissKnife.PersistentCache.BRSCache do
  @moduledoc false
  use TypedStruct

  alias UrFUAPI.IStudent.BRS.Subject

  typedstruct strict: true do
    field :id, integer()
    field :subjects, [Subject.t()]
  end

  @spec new(integer(), [Subject.t()]) :: t()
  def new(id, subjects) do
    %__MODULE__{id: id, subjects: subjects}
  end
end
