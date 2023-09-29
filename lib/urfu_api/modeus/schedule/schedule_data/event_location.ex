defmodule UrFUAPI.Modeus.Schedule.ScheduleData.EventLocation do
  use TypedStruct

  typedstruct enforce: true do
    field :event_id, String.t()
    field :custom_location, String.t() | nil
    field :links, map()
  end

  use ExConstructor
end
