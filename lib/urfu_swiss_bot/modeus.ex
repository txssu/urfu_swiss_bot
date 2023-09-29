defmodule UrFUSwissBot.Modeus do
  alias UrFUAPI.Modeus.Schedule.ScheduleData
  alias UrFUAPI.Modeus.Schedule.ScheduleData.Event
  alias UrFUAPI.Modeus.Auth.Token
  alias UrFUAPI.Modeus.Auth.TokenClaims
  alias UrFUSwissBot.Cache
  alias UrFUSwissBot.Utils

  use Nebulex.Caching

  alias UrFUSwissBot.Repo.User

  def register_user(user, username, password) do
    authed_user = User.set_credentials(user, username, password)

    case auth_user(authed_user) do
      {:ok, _auth} ->
        {:ok, authed_user}

      err ->
        err
    end
  end

  @decorate cacheable(cache: Cache, key: {:modeus_auth, username, password}, match: &match_auth/1)
  def auth_user(%User{username: username, password: password}) do
    UrFUAPI.Modeus.Auth.sign_in(username, password)
  end

  def match_auth({:ok, %Token{claims: %TokenClaims{exp: expires}}} = result) do
    ttl = DateTime.to_unix(expires, :millisecond) - System.os_time(:millisecond)

    {true, result, [ttl: ttl]}
  end

  def match_auth({:error, _}) do
    false
  end

  alias UrFUAPI.Modeus.Auth.Token
  alias UrFUAPI.Modeus.Auth.TokenClaims

  def get_schedule_by_day(auth, datetime) do
    before_time = Utils.start_of_next_day(datetime)
    get_schedule(auth, datetime, before_time)
  end

  def get_schedule_for_week(auth, datetime) do
    before_time = Utils.start_of_day_after(datetime, 7)
    get_schedule(auth, datetime, before_time)
  end

  @spec get_upcoming_schedule(Token.t(), DateTime.t()) :: {Date.t(), ScheduleData.t()} | :empty
  def get_upcoming_schedule(auth, datetime) do
    case get_schedule_for_week(auth, datetime) do
      %ScheduleData{events: []} ->
        :empty

      %ScheduleData{events: events} = schedule ->
        events_by_days = Enum.group_by(events, fn event -> DateTime.to_date(event.starts_at) end)
        days = Map.keys(events_by_days)
        first_day = Enum.min(days, Date)

        events_at_first_day = Map.fetch!(events_by_days, first_day)

        {first_day, %{schedule | events: events_at_first_day}}
    end
  end

  @decorate cacheable(
              cache: Cache,
              key:
                {:get_schedule, extract_person_id(auth), DateTime.to_unix(after_time),
                 DateTime.to_unix(before_time)},
              ttl: :timer.hours(8)
            )
  def get_schedule(auth, after_time, before_time) do
    %ScheduleData{events: all_events} =
      schedule = UrFUAPI.Modeus.Schedule.get_schedule(auth, after_time, before_time)

    events =
      all_events
      |> Enum.reject(&first_or_last_event_of_day?/1)

    %{schedule | events: events}
  end

  defp first_or_last_event_of_day?(%Event{starts_at_local: starts_at}) do
    time = DateTime.to_time(starts_at)

    Time.before?(time, ~T[08:00:00]) or Time.after?(time, ~T[20:00:00])
  end

  defp extract_person_id(%Token{claims: %TokenClaims{person_id: person_id}}), do: person_id
end
