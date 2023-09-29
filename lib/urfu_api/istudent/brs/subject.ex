defmodule UrFUAPI.IStudent.BRS.Subject do
  alias UrFUAPI.IStudent.BRS.SubjectScore

  use TypedStruct

  typedstruct enforce: true do
    field :id, pos_integer()
    field :name, String.t()
    field :total, float()
    field :grade, String.t()
    field :scores, [SubjectScore.t()] | nil
  end

  use ExConstructor
end
