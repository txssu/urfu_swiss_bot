defmodule UrFUAPI.Modeus.Schedule.ScheduleData.EducationalObject do
  use TypedStruct

  typedstruct enforce: true do
    field :id, String.t()
    field :external_object_id, String.t()
    field :type_code, String.t()
    field :links, map()
  end

  use ExConstructor
end
