defmodule UrFUAPI.Modeus.Schedule.ScheduleData.EventOrganizer do
  use TypedStruct

  typedstruct enforce: true do
    field(:event_id, String.t())
    field(:links, map())
  end

  use ExConstructor
end
