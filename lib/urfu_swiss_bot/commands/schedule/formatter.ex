defmodule UrfuSwissBot.Commands.Schedule.Formatter do
  @moduledoc false
  alias UrfuApi.Modeus.Schedule
  alias UrfuApi.Modeus.Schedule.ScheduleData
  alias UrfuApi.Modeus.Schedule.ScheduleData.Event
  alias UrfuApi.Modeus.Schedule.ScheduleData.EventLocation
  alias UrFUSwissKnife.Utils

  @spec format_events(ScheduleData.t(), Date.t() | DateTime.t()) :: String.t()
  def format_events(%ScheduleData{events: events} = schedule, datetime) do
    events
    |> Enum.sort_by(& &1.starts_at, DateTime)
    |> Enum.map_join("\n\n", &format_event(&1, schedule, datetime))
  end

  @spec format_event(Event.t(), ScheduleData.t(), DateTime.t()) :: String.t()
  def format_event(
        %Event{starts_at_local: starts_at, ends_at_local: ends_at, type_id: type_id} = event,
        schedule,
        datetime
      ) do
    name = get_name_from_event(event, schedule)
    formatted_starts_at = format_datetime(starts_at)
    formatted_ends_at = format_datetime(ends_at)
    time = "#{formatted_starts_at} – #{formatted_ends_at}"
    {color, type} = convert_type_id(type_id)
    address = get_address_from_event(event, schedule)
    status = get_status(event, datetime)

    [{:unescape, status}, time, color <> name, type, address]
    |> Enum.map(&Utils.escape_telegram_markdown/1)
    |> Enum.filter(fn
      "" -> false
      _not_empty -> true
    end)
    |> Enum.join("\n")
  end

  @spec get_name_from_event(Event.t(), ScheduleData.t()) :: String.t()
  defp get_name_from_event(event, schedule) do
    event
    |> Schedule.fetch_by_link!("cycle_realization", schedule)
    |> Map.fetch!(:course_unit_realization_name_short)
  end

  @spec format_datetime(DateTime.t()) :: String.t()
  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end

  @spec convert_type_id(String.t()) :: {String.t(), String.t()}
  defp convert_type_id(type_id)
  defp convert_type_id("SEMI"), do: {"🔵", "Практика"}
  defp convert_type_id("SELF"), do: {"🔵", "Самостоятельная работа"}
  defp convert_type_id("LECT"), do: {"🟢", "Лекция"}
  defp convert_type_id("LAB"), do: {"🟠", "Лабораторная работа"}
  defp convert_type_id("CONS"), do: {"🟢", "Консультация"}
  defp convert_type_id("MID_CHECK"), do: {"🟣", "Экзамен"}
  defp convert_type_id(_another), do: {"", ""}

  @spec get_address_from_event(Event.t(), ScheduleData.t()) :: String.t()
  def get_address_from_event(event, schedule) do
    location = Schedule.fetch_by_link!(event, "location", schedule)

    case location.custom_location do
      nil ->
        format_address(location, schedule)

      custom_location ->
        custom_location
    end
  end

  @spec format_address(EventLocation.t(), ScheduleData.t()) :: String.t()
  defp format_address(location, schedule) do
    case Schedule.fetch_by_link(location, "event_rooms", schedule) do
      {:ok, event_rooms} ->
        %{name_short: room_number, building: %{"address" => address}} =
          Schedule.fetch_by_link!(event_rooms, "room", schedule)

        "#{room_number}, #{address}"

      :error ->
        ""
    end
  end

  @spec get_status(Event.t(), DateTime.t()) :: String.t()
  defp get_status(event, datetime) do
    cond do
      ongoing?(event, datetime) -> "*Сейчас идёт:*"
      impending?(event, datetime) -> "*Скоро начнётся:*"
      true -> ""
    end
  end

  @spec impending?(Event.t(), DateTime.t()) :: boolean()
  defp impending?(%Event{starts_at: starts_at}, datetime) do
    impending_at = DateTime.add(starts_at, -90, :minute)

    DateTime.after?(datetime, impending_at) and DateTime.before?(datetime, starts_at)
  end

  @spec ongoing?(Event.t(), DateTime.t()) :: boolean()
  defp ongoing?(%Event{starts_at: starts_at, ends_at: ends_at}, datetime) do
    DateTime.after?(datetime, starts_at) and DateTime.before?(datetime, ends_at)
  end
end
