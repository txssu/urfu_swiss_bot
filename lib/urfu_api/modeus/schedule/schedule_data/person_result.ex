defmodule UrFUAPI.Modeus.Schedule.ScheduleData.PersonResult do
  # TODO
  use TypedStruct

  typedstruct enforce: true do
    field(:links, map())
  end

  use ExConstructor
end
