defmodule UrFUAPI.Modeus.Schedule.ScheduleData.Duration do
  use TypedStruct

  typedstruct enforce: true do
    field(:event_id, String.t())
    field(:minutes, integer())
    field(:time_unit_id, String.t())
    field(:value, integer())
    field(:links, map())
  end

  use ExConstructor
end
