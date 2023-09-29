defmodule UrFUAPI.Modeus.Schedule.ScheduleData.LessonRealizationTeam do
  use TypedStruct

  typedstruct enforce: true do
    field(:id, String.t())
    field(:name, String.t())
    field(:links, map())
  end

  use ExConstructor
end
