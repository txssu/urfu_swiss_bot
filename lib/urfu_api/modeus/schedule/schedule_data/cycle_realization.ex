defmodule UrFUAPI.Modeus.Schedule.ScheduleData.CycleRealization do
  use TypedStruct

  typedstruct enforce: true do
    field(:id, String.t())
    field(:name, String.t())
    field(:name_short, String.t())
    field(:code, String.t())
    field(:course_unit_realization_name_short, String.t())
    field(:links, map())
  end

  use ExConstructor
end
