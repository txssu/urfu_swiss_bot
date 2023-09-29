defmodule UrFUAPI.Modeus.Schedule.ScheduleData.CourseUnitRealization do
  use TypedStruct

  typedstruct enforce: true do
    field(:id, String.t())
    field(:name, String.t())
    field(:name_short, String.t())
    field(:prototype_id, String.t())
    field(:links, map())
  end

  use ExConstructor
end
