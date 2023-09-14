defmodule UrFUSwissBot.Modeus.ScheduleAPI do
  use Tesla
  alias UrFUSwissBot.Cache

  use Nebulex.Caching

  alias UrFUSwissBot.Utils

  plug Tesla.Middleware.BaseUrl, "https://urfu.modeus.org/schedule-calendar-v2/api/"
  plug Tesla.Middleware.JSON

  @decorate cacheable(
              cache: Cache,
              key: {auth.person_id, DateTime.to_unix(datetime)},
              ttl: :timer.hours(8),
              match: &match_events/1
            )
  def get_events_by_day(auth, datetime) do
    get_events(auth, datetime, Utils.start_of_next_day(datetime))
  end

  def get_events_for_week(auth, datetime) do
    get_events(auth, datetime, Utils.start_of_day_after(datetime, 7))
  end

  def get_events(auth, time_min, time_max) do
    body = %{
      attendeePersonId: [auth.person_id],
      timeMin: DateTime.to_iso8601(time_min),
      timeMax: DateTime.to_iso8601(time_max),
      size: 500
    }

    case post("calendar/events/search", body, auth_header(auth.access_token)) do
      {:ok, response} -> {:ok, response.body["_embedded"]}
      err -> err
    end
  end

  def match_events({:ok, _} = result), do: {true, result}
  def match_events({:error, _}), do: false

  defp auth_header(token) do
    [headers: [{"Authorization", "Bearer #{token}"}]]
  end
end
