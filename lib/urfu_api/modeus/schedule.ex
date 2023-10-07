defmodule UrFUAPI.Modeus.Schedule do
  alias UrFUAPI.Modeus.Auth.Token
  alias UrFUAPI.Modeus.Auth.TokenClaims
  alias UrFUAPI.Modeus.Headers
  alias UrFUAPI.Modeus.Schedule.Client
  alias UrFUAPI.Modeus.Schedule.ScheduleData

  defmodule Client do
    use Tesla

    plug Tesla.Middleware.BaseUrl, "https://urfu.modeus.org/schedule-calendar-v2/api"
    plug Tesla.Middleware.JSON
  end

  @spec get_schedule(Token.t(), DateTime.t(), DateTime.t()) :: ScheduleData.t()
  def get_schedule(
        %Token{claims: %TokenClaims{person_id: person_id}} = auth,
        after_time,
        before_time
      ) do
    body = %{
      attendeePersonId: [person_id],
      timeMin: DateTime.to_iso8601(after_time),
      timeMax: DateTime.to_iso8601(before_time),
      size: 500
    }

    %{body: %{"_embedded" => database}} =
      Client.post!("/calendar/events/search", body, Headers.from_token(auth))

    ScheduleData.new(database)
  end

  @spec fetch_by_link(map, String.t(), ScheduleData.t()) :: {:ok, map()} | :error
  defdelegate fetch_by_link(item, link_name, database), to: ScheduleData

  @spec fetch_by_link!(map, String.t(), ScheduleData.t()) :: map()
  defdelegate fetch_by_link!(item, link_name, database), to: ScheduleData
end
