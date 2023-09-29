defmodule UrFUAPI.Modeus.Schedule do
  alias UrFUAPI.Modeus.Auth.Token

  alias UrFUAPI.Modeus.Schedule.API
  alias UrFUAPI.Modeus.Schedule.ScheduleData

  @spec get_schedule(Token.t(), DateTime.t(), DateTime.t()) :: ScheduleData.t()
  defdelegate get_schedule(auth, after_time, before_time), to: API

  @spec fetch_by_link(map, String.t(), ScheduleData.t()) :: {:ok, any()} | :error
  defdelegate fetch_by_link(item, link_name, database), to: ScheduleData

  @spec fetch_by_link!(map, String.t(), ScheduleData.t()) :: any()
  defdelegate fetch_by_link!(item, link_name, database), to: ScheduleData
end
