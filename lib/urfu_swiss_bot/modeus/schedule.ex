defmodule UrFUSwissBot.Modeus.Schedule do
  alias UrFUSwissBot.Modeus.ScheduleAPI

  def get_schedule_by_day(auth, datetime) do
    case ScheduleAPI.get_lessons_by_day(auth, datetime) do
      {:ok, schedule} -> {:ok, format_events(schedule)}
      err -> err
    end
  end

  @spec format_events(map) :: String.t()
  def format_events(schedule) do
    case Map.fetch(schedule, "events") do
      :error ->
        ""

      {:ok, events} ->
        events
        |> Enum.sort_by(&get_event_start_time/1, DateTime)
        |> Enum.map_join("\n\n", &__MODULE__.to_string(&1, schedule))
    end
  end

  @spec to_string(map, map) :: String.t()
  def to_string(event, schedule) do
    name = get_name_from_event(event, schedule)

    {color, type} = event["typeId"] |> event_type_id_to_type()

    starts_at = get_event_start_time(event)
    ends_at = get_event_end_time(event)
    time = "#{format_datetime(starts_at)} - #{format_datetime(ends_at)}"

    address = get_address_from_event(event, schedule)

    [color <> name, type, time, address]
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
    |> Enum.join("\n")
  end

  defp event_type_id_to_type(typeID)
  defp event_type_id_to_type("SEMI"), do: {"🔵", "Практика"}
  defp event_type_id_to_type("SELF"), do: {"🔵", "Самостоятельная работа"}
  defp event_type_id_to_type("LECT"), do: {"🟢", "Лекция"}
  defp event_type_id_to_type("LAB"), do: {"🟠", "Лабораторная работа"}
  defp event_type_id_to_type("CONS"), do: {"🟢", "Консультация"}
  defp event_type_id_to_type("MID_CHECK"), do: {"🟣", "Экзамен"}
  defp event_type_id_to_type(_another), do: {"", ""}

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end

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
      (event["startsAtLocal"] <> "Z")
      |> DateTime.from_iso8601()

    starts_at
  end

  @spec get_event_end_time(map) :: DateTime.t()
  def get_event_end_time(event) do
    {:ok, ends_at, _} =
      (event["endsAtLocal"] <> "Z")
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
