defmodule UrFUSwissKnife.Utils do
  @moduledoc false
  @type weekday :: 1 | 2 | 3 | 4 | 5 | 6 | 7

  @spec start_of_next_day(DateTime.t()) :: DateTime.t()
  def start_of_next_day(datetime) do
    start_of_day_after(datetime, 1)
  end

  @spec start_of_previous_day(DateTime.t()) :: DateTime.t()
  def start_of_previous_day(datetime) do
    start_of_day_after(datetime, -1)
  end

  @spec start_of_day_after(DateTime.t(), integer()) :: DateTime.t()
  def start_of_day_after(datetime, days) do
    datetime
    |> DateTime.add(days, :day)
    |> start_of_day()
  end

  @spec start_of_day(DateTime.t()) :: DateTime.t()
  def start_of_day(datetime) do
    datetime
    |> DateTime.to_date()
    |> DateTime.new!(~T[00:00:00])
  end

  @spec to_yekaterinburg_zone(DateTime.t()) :: DateTime.t()
  def to_yekaterinburg_zone(datetime) do
    DateTime.shift_zone!(datetime, "Asia/Yekaterinburg")
  end

  @spec utc_as_yekaterinburg_zone(DateTime.t()) :: DateTime.t()
  def utc_as_yekaterinburg_zone(datetime) do
    datetime
    |> DateTime.shift_zone!("Asia/Yekaterinburg")
    |> DateTime.add(5, :hour)
  end

  @spec yekaterinburg_start_of_day(DateTime.t()) :: DateTime.t()
  def yekaterinburg_start_of_day(datetime) do
    datetime
    |> to_yekaterinburg_zone()
    |> start_of_day()
    |> utc_as_yekaterinburg_zone()
  end

  @spec month_to_russian(1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12) :: String.t()
  def month_to_russian(month)
  def month_to_russian(1), do: "Января"
  def month_to_russian(2), do: "Февраля"
  def month_to_russian(3), do: "Марта"
  def month_to_russian(4), do: "Апреля"
  def month_to_russian(5), do: "Мая"
  def month_to_russian(6), do: "Июня"
  def month_to_russian(7), do: "Июля"
  def month_to_russian(8), do: "Августа"
  def month_to_russian(9), do: "Сентября"
  def month_to_russian(10), do: "Октября"
  def month_to_russian(11), do: "Ноября"
  def month_to_russian(12), do: "Декабря"

  @spec weekday_to_russian(weekday()) :: String.t()
  def weekday_to_russian(weekday)
  def weekday_to_russian(1), do: "Понедельник"
  def weekday_to_russian(2), do: "Вторник"
  def weekday_to_russian(3), do: "Среда"
  def weekday_to_russian(4), do: "Четверг"
  def weekday_to_russian(5), do: "Пятница"
  def weekday_to_russian(6), do: "Суббота"
  def weekday_to_russian(7), do: "Воскресенье"

  @spec russian_to_weekday(String.t()) :: :error | {:ok, weekday()}
  def russian_to_weekday(weekday)
  def russian_to_weekday("понедельник"), do: {:ok, 1}
  def russian_to_weekday("вторник"), do: {:ok, 2}
  def russian_to_weekday("среда"), do: {:ok, 3}
  def russian_to_weekday("четверг"), do: {:ok, 4}
  def russian_to_weekday("пятница"), do: {:ok, 5}
  def russian_to_weekday("суббота"), do: {:ok, 6}
  def russian_to_weekday("воскресенье"), do: {:ok, 7}
  def russian_to_weekday(_others), do: :error

  @spec parse_russian_date(String.t()) :: {:ok, DateTime.t()} | :error
  def parse_russian_date(text) do
    case String.split(text, ".") do
      [number_or_weekday] ->
        parse_date_from_word(number_or_weekday)

      lst ->
        parse_date_from_list(lst)
    end
  end

  @spec parse_date_from_word(String.t()) :: {:ok, DateTime.t()} | :error
  def parse_date_from_word(number_or_weekday) do
    case Integer.parse(number_or_weekday) do
      {day, ""} ->
        datetime_in_future(day)

      _not_a_number ->
        result =
          number_or_weekday
          |> String.downcase()
          |> russian_to_weekday()

        case result do
          {:ok, weekday} -> datetime_in_future_by_weekday(weekday)
          :error -> :error
        end
    end
  end

  @spec parse_date_from_list([String.t()]) :: {:ok, DateTime.t()} | :error
  def parse_date_from_list(lst) do
    maybe_ints =
      lst
      |> Enum.map(&Integer.parse/1)
      |> unpack_integers()

    case maybe_ints do
      :error -> :error
      {:ok, ints} -> date_from_list(ints)
    end
  end

  @spec unpack_integers([{integer(), String.t()}], [integer()]) :: {:ok, [integer()]} | :error
  defp unpack_integers(list, result \\ [])

  defp unpack_integers([], result) do
    {:ok, result}
  end

  defp unpack_integers([{n, ""} | rest], result) do
    unpack_integers(rest, [n | result])
  end

  defp unpack_integers([_another | _rest], _result) do
    :error
  end

  @spec date_from_list([integer()]) :: {:ok, DateTime.t()} | :error
  defp date_from_list([month, day]) do
    year = Date.utc_today().year

    date_from_list([year, month, day])
  end

  defp date_from_list([year, month, day]) do
    corrected_year =
      if year < 100 do
        year + 2000
      else
        year
      end

    case Date.from_erl({corrected_year, month, day}) do
      {:ok, date} -> DateTime.new(date, ~T[00:00:00])
      _err -> :error
    end
  end

  defp date_from_list(_not_date) do
    :error
  end

  @spec datetime_in_future(integer()) :: {:ok, DateTime.t()} | :error
  defp datetime_in_future(day) do
    today = Date.utc_today()

    month =
      if today.day < day do
        today.month
      else
        today.month + 1
      end

    date_from_list([month, day])
  end

  @spec datetime_in_future_by_weekday(weekday()) :: {:ok, DateTime.t()}
  defp datetime_in_future_by_weekday(weekday) do
    today = Date.utc_today()
    weekday_today = Date.day_of_week(today)

    future_date =
      if weekday_today < weekday do
        Date.add(today, weekday - weekday_today)
      else
        Date.add(today, 7 + weekday - weekday_today)
      end

    DateTime.new(future_date, ~T[00:00:00])
  end
end
