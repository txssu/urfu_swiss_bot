defmodule UrFUAPI.Modeus.Schedule.ScheduleData.Building do
  use TypedStruct

  typedstruct enforce: true do
    field :id, String.t()
    field :address, String.t()
    field :display_order, integer()
    field :name, String.t()
    field :name_short, String.t()
    field :searchable_address, String.t()
    field :links, map()
  end

  use ExConstructor
end
