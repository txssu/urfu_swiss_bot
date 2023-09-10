defmodule UrFUSwissBot.Modeus.Schedule do
  alias UrFUSwissBot.Modeus.AuthAPI
  alias UrFUSwissBot.Modeus.Models.Event
  alias UrFUSwissBot.Modeus.ScheduleAPI

  @spec get_schedule_by_day(AuthAPI.t(), DateTime.t()) :: {:ok, [Event.t()]} | {:error, any}
  def get_schedule_by_day(auth, datetime) do
    case ScheduleAPI.get_events_by_day(auth, datetime) do
      {:ok, schedule} -> {:ok, to_events(schedule)}
      err -> err
    end
  end

  def get_schedule_for_week(auth, datetime) do
    case ScheduleAPI.get_events_for_week(auth, datetime) do
      {:ok, schedule} -> {:ok, to_events(schedule)}
      err -> err
    end
  end

  def get_upcoming_events(auth, datetime) do
    case get_schedule_for_week(auth, datetime) do
      {:ok, []} ->
        {:ok, datetime, []}

      {:ok, events} ->
        events_by_days = Enum.group_by(events, fn event -> DateTime.to_date(event.starts_at) end)
        days = Map.keys(events_by_days)
        first_day = Enum.min(days, Date)

        {:ok, first_day, Map.fetch!(events_by_days, first_day)}

      err ->
        err
    end
  end

  @spec to_events(map) :: [Event.t()]
  def to_events(schedule) do
    Map.get(schedule, "events", [])
    |> Enum.map(&to_event(&1, schedule))
    |> Enum.reject(&first_or_last_event_of_day?/1)
    |> Enum.sort_by(&(&1.starts_at), DateTime)
  end

  @local_8_00 ~T[03:00:00]
  @local_20_00 ~T[15:00:00]

  defp first_or_last_event_of_day?(event) do
    time = DateTime.to_time(event.starts_at)

    Time.before?(time, @local_8_00) or Time.after?(time, @local_20_00)
  end

  @spec to_event(map, map) :: Event.t()
  def to_event(event, schedule) do
    name = get_name_from_event(event, schedule)

    {color, type} = convert_type_id(event["typeId"])

    starts_at = get_event_start_time(event)
    ends_at = get_event_end_time(event)
    address = get_address_from_event(event, schedule)

    %Event{
      name: name,
      color: color,
      type: type,
      starts_at: starts_at,
      ends_at: ends_at,
      address: address
    }
  end

  defp convert_type_id(typeID)
  defp convert_type_id("SEMI"), do: {"🔵", "Практика"}
  defp convert_type_id("SELF"), do: {"🔵", "Самостоятельная работа"}
  defp convert_type_id("LECT"), do: {"🟢", "Лекция"}
  defp convert_type_id("LAB"), do: {"🟠", "Лабораторная работа"}
  defp convert_type_id("CONS"), do: {"🟢", "Консультация"}
  defp convert_type_id("MID_CHECK"), do: {"🟣", "Экзамен"}
  defp convert_type_id(_another), do: {"", ""}

  @spec get_name_from_event(map, map) :: String.t()
  def get_name_from_event(event, schedule) do
    case get(event, schedule, "cycle-realization") do
      {:ok, cycle_realization} -> cycle_realization["courseUnitRealizationNameShort"]
      :error -> ""
    end
  end

  @spec get_address_from_event(map, map) :: String.t()
  def get_address_from_event(event, schedule) do
    with {:ok, location} <- get(event, schedule, "location"),
         {:ok, event_rooms} <- get(location, schedule, "event-rooms"),
         {:ok, room} <- get(event_rooms, schedule, "room"),
         {:ok, room_number} <- get(room, schedule, "nameShort"),
         {:ok, address} <- get(room["building"], schedule, "address") do
      "#{room_number}, #{address}"
    else
      :error -> ""
    end
  end

  @spec get_event_start_time(map) :: DateTime.t()
  def get_event_start_time(event) do
    {:ok, starts_at, _} =
      (event["startsAt"] <> "Z")
      |> DateTime.from_iso8601()

    starts_at
  end

  @spec get_event_end_time(map) :: DateTime.t()
  def get_event_end_time(event) do
    {:ok, ends_at, _} =
      (event["endsAt"] <> "Z")
      |> DateTime.from_iso8601()

    ends_at
  end

  @spec get(map, map, String.t()) :: :error | {:ok, map | list | String.t()}
  def get(obj, schedule, field) do
    case Map.fetch(obj, field) do
      {:ok, value} -> {:ok, value}
      :error -> get_by_link(obj, schedule, field)
    end
  end

  @spec get_by_link(map, map, String.t()) :: :error | {:ok, map}
  def get_by_link(obj, schedule, field) do
    case get_path_from_links(obj, field) do
      {:ok, path} -> {:ok, follow_path(schedule, path)}
      :error -> :error
    end
  end

  @spec get_path_from_links(map, String.t()) :: :error | {:ok, binary}
  def get_path_from_links(obj, field) do
    case Map.fetch(obj["_links"], field) do
      {:ok, links} ->
        {:ok, field_to_key(field) <> Map.fetch!(links, "href")}

      :error ->
        :error
    end
  end

  defp field_to_key(field_name)
  defp field_to_key("location"), do: "event-locations"
  defp field_to_key("organizers"), do: "event-organizers"
  defp field_to_key("team"), do: "event-teams"
  defp field_to_key("event-rooms"), do: "event-rooms"
  defp field_to_key(key), do: key <> "s"

  @spec follow_path(map, String.t()) :: any
  def follow_path(schedule, path) do
    get_by_path(schedule, String.split(path, "/"))
  end

  defp get_by_path(_, ["formats", format]), do: format

  defp get_by_path(schedule, [key, id]) do
    schedule[key]
    |> Enum.find(fn x -> x["id"] == id end)
  end

  defp get_by_path(schedule, [key, id, _]) do
    schedule[key]
    |> Enum.find(fn x -> x["eventId"] == id end)
  end
end
