defmodule UrFUSwissBot.Modeus do
  alias UrFUAPI.Modeus.Auth
  alias UrFUAPI.Modeus.Auth.Token
  alias UrFUAPI.Modeus.Auth.TokenClaims
  alias UrFUAPI.Modeus.Schedule
  alias UrFUAPI.Modeus.Schedule.ScheduleData
  alias UrFUAPI.Modeus.Schedule.ScheduleData.Event

  alias UrFUSwissBot.Cache
  alias UrFUSwissBot.Utils

  use Nebulex.Caching

  @decorate cacheable(cache: Cache, key: {:modeus_auth, username, password}, match: &match_auth/1)
  @spec auth_user(map()) :: {:ok, Token.t()} | {:error, String.t()}
  def auth_user(%{username: username, password: password}) do
    Auth.sign_in(username, password)
  end

  @spec match_auth({:ok, Token.t()} | {:error, String.t()}) ::
          false | {true, {:ok, Token.t()}, [{:ttl, integer}, ...]}
  def match_auth({:ok, %Token{claims: %TokenClaims{exp: expires}}} = result) do
    ttl = DateTime.to_unix(expires, :millisecond) - System.os_time(:millisecond)

    {true, result, [ttl: ttl]}
  end

  def match_auth({:error, _}) do
    false
  end

  @spec get_schedule_by_day(Token.t(), DateTime.t()) :: ScheduleData.t()
  def get_schedule_by_day(auth, datetime) do
    before_time = Utils.start_of_next_day(datetime)
    get_schedule(auth, datetime, before_time)
  end

  @spec get_schedule_for_week(Token.t(), DateTime.t()) :: ScheduleData.t()
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
  @spec get_schedule(Token.t(), DateTime.t(), DateTime.t()) :: ScheduleData.t()
  def get_schedule(auth, after_time, before_time) do
    %ScheduleData{events: all_events} =
      schedule = Schedule.get_schedule(auth, after_time, before_time)

    events =
      Enum.reject(all_events, &first_or_last_event_of_day?/1)

    %{schedule | events: events}
  end

  @spec first_or_last_event_of_day?(Event.t()) :: boolean()
  defp first_or_last_event_of_day?(%Event{starts_at_local: starts_at}) do
    time = DateTime.to_time(starts_at)

    Time.before?(time, ~T[08:00:00]) or Time.after?(time, ~T[20:00:00])
  end

  @spec extract_person_id(Token.t()) :: integer()
  defp extract_person_id(%Token{claims: %TokenClaims{person_id: person_id}}), do: person_id
end
