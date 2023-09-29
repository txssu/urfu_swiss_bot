defmodule UrFUAPI.Modeus.Schedule.ScheduleData.LessonRealization do
  use TypedStruct

  typedstruct enforce: true do
    field(:id, String.t())
    field(:name, String.t())
    field(:name_short, String.t())
    field(:ordinal, integer())
    field(:prototype_id, String.t())
    field(:links, map())
  end

  use ExConstructor
end
