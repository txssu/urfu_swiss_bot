defmodule UrFUAPI.Modeus.Schedule.API do
  alias UrFUAPI.Modeus.Auth.Token
  alias UrFUAPI.Modeus.Auth.TokenClaims
  alias UrFUAPI.Modeus.Schedule.Client
  alias UrFUAPI.Modeus.Schedule.ScheduleData

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
      Client.post!("/calendar/events/search", body, Client.headers(auth))

    ScheduleData.new(database)
  end
end
