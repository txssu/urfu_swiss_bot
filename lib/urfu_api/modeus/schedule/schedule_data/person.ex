defmodule UrFUAPI.Modeus.Schedule.ScheduleData.Person do
  use TypedStruct

  typedstruct enforce: true do
    field(:id, String.t())
    field(:first_name, String.t())
    field(:last_name, String.t())
    field(:middle_name, String.t())
    field(:full_name, String.t())
    field(:links, map())
  end

  use ExConstructor
end