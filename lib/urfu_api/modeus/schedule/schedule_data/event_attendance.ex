defmodule UrFUAPI.Modeus.Schedule.ScheduleData.EventAttendance do
  # TODO
  use TypedStruct

  typedstruct enforce: true do
    field(:links, map())
  end

  use ExConstructor
end
