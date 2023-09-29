defmodule UrFUAPI.IStudent.BRS.SubjectScore do
  use TypedStruct

  typedstruct enforce: true do
    field(:name, String.t())
    field(:raw, float())
    field(:multiplier, float())
    field(:total, float())
  end

  use ExConstructor
end
