defmodule UrFUAPI.Modeus.Schedule.ScheduleData.Room do
  alias UrFUAPI.Modeus.Schedule.ScheduleData.Building

  use TypedStruct

  typedstruct enforce: true do
    field :id, String.t()
    field :building, Building.t()
    field :deleted_at_utc, DateTime.t() | nil
    field :name, String.t()
    field :name_short, String.t()
    field :projector_available, boolean()
    field :total_capacity, integer()
    field :working_capacity, integer()
    field :links, map()
  end

  use ExConstructor
end
