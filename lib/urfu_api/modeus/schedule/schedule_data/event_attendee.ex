defmodule UrFUAPI.Modeus.Schedule.ScheduleData.EventAttendee do
  use TypedStruct

  typedstruct enforce: true do
    field(:id, String.t())
    field(:links, map())
  end

  use ExConstructor
end
