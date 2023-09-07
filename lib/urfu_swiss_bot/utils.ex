defmodule UrFUSwissBot.Utils do
  def start_of_next_day(datetime) do
    datetime
    |> DateTime.add(1, :day)
    |> truncate_time()
  end

  def start_of_previous_day(datetime) do
    datetime
    |> DateTime.add(-1, :day)
    |> truncate_time()
  end

  @spec truncate_time(DateTime.t()) :: DateTime.t()
  def truncate_time(datetime) do
    %{datetime | hour: 0, minute: 0, second: 0}
  end

  @spec month_to_russian(1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12) :: String.t()
  def month_to_russian(month)
  def month_to_russian(1), do: "Января"
  def month_to_russian(2), do: "Феврала"
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

  @spec weekday_to_russian(1 | 2 | 3 | 4 | 5 | 6 | 7) :: String.t()
  def weekday_to_russian(weekday)
  def weekday_to_russian(1), do: "Понедельник"
  def weekday_to_russian(2), do: "Вторник"
  def weekday_to_russian(3), do: "Среда"
  def weekday_to_russian(4), do: "Четверг"
  def weekday_to_russian(5), do: "Пятница"
  def weekday_to_russian(6), do: "Суббота"
  def weekday_to_russian(7), do: "Воскресенье"

  def russian_to_weekday(weekday)
  def russian_to_weekday("понедельник"), do: {:ok, 1}
  def russian_to_weekday("вторник"), do: {:ok, 2}
  def russian_to_weekday("среда"), do: {:ok, 3}
  def russian_to_weekday("четверг"), do: {:ok, 4}
  def russian_to_weekday("пятница"), do: {:ok, 5}
  def russian_to_weekday("суббота"), do: {:ok, 6}
  def russian_to_weekday("воскресенье"), do: {:ok, 7}
  def russian_to_weekday(_), do: :error

  def parse_russian_date(text) do
    case String.split(text, ".") do
      [number_or_weekday] ->
        parse_date_from_word(number_or_weekday)

      lst ->
        parse_date_from_list(lst)
    end
  end

  def parse_date_from_word(number_or_weekday) do
    case Integer.parse(number_or_weekday) do
      {day, _} ->
        datetime_in_future(day)

      _ ->
        number_or_weekday
        |> String.downcase()
        |> russian_to_weekday()
        |> case do
          {:ok, weekday} -> datetime_in_future_by_weekday(weekday)
          :error -> :error
        end
    end
  end

  def parse_date_from_list(lst) do
    maybe_ints =
      Enum.map(lst, &Integer.parse/1)
      |> unpack_integers()

    case maybe_ints do
      :error -> :error
      {:ok, ints} -> date_from_list(ints)
    end
  end

  defp unpack_integers(list, result \\ [])

  defp unpack_integers([], result) do
    {:ok, result}
  end

  defp unpack_integers([{n, _} | rest], result) do
    unpack_integers(rest, [n | result])
  end

  defp unpack_integers([_another | _rest], _result) do
    :error
  end

  defp date_from_list([month, day]) do
    year = Date.utc_today().year

    date_from_list([year, month, day])
  end

  defp date_from_list([year, month, day]) do
    case Date.from_erl({year, month, day}) do
      {:ok, date} -> DateTime.new(date, ~T[00:00:00])
      _err -> :error
    end
  end

  defp date_from_list(_) do
    :error
  end

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

  defp datetime_in_future_by_weekday(weekday) do
    today = Date.utc_today()
    weekday_today = Date.day_of_week(today)

    if weekday_today < weekday do
      Date.add(today, weekday - weekday_today)
    else
      Date.add(today, 7 + weekday - weekday_today)
    end
    |> DateTime.new(~T[00:00:00])
  end
end
