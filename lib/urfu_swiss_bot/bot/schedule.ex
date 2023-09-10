defmodule UrFUSwissBot.Bot.Schedule do
  alias UrFUSwissBot.Modeus.Models.Event
  alias UrFUSwissBot.Modeus
  alias UrFUSwissBot.Repo.User
  alias UrFUSwissBot.Utils

  import ExGram.Dsl
  require ExGram.Dsl

  import ExGram.Dsl.Keyboard
  require ExGram.Dsl.Keyboard

  @start_text """
  Вы можете нажать кнопку, отправить день недели или дату.
  Вместо 25.09.2023 вы также можете написать 25.09 или просто 25
  """

  @today_no_more_lessons """
  Пары закончились. Пора отдыхать 😼
  """

  @tommorow_no_lessons """
  Завтра нет пар. Можно отметить🥴
  """

  @no_lessons """
  В этот день пар нет.
  """

  @parse_error """
  Вы ввели дату в неверном формате
  """

  @start_keyboard (keyboard :inline do
                     row do
                       button("Сегодня⬇️", callback_data: "schedule-today")
                       button("Завтра➡️", callback_data: "schedule-tomorrow")
                     end

                     row do
                       button("Меню", callback_data: "menu")
                     end
                   end)

  defp keyboard_next(datetime) do
    previous_day = Utils.start_of_previous_day(datetime) |> DateTime.to_iso8601(:basic)
    next_day = Utils.start_of_next_day(datetime) |> DateTime.to_iso8601(:basic)

    keyboard :inline do
      row do
        button("⬅️", callback_data: "schedule-date-#{previous_day}")
        button("➡️", callback_data: "schedule-date-#{next_day}")
      end

      row do
        button("Меню", callback_data: "menu")
      end
    end
  end

  def handle({:callback_query, %{data: "schedule"} = callback_query}, context) do
    context.extra.user
    |> User.set_state({__MODULE__, :date})
    |> User.save()

    context
    |> answer_callback(callback_query)
    |> edit(:inline, @start_text, reply_markup: @start_keyboard)
  end

  def handle({:callback_query, %{data: "schedule-today"} = callback_query}, context) do
    today = DateTime.utc_now()

    reply_callback(context, callback_query, today, @today_no_more_lessons)
  end

  def handle({:callback_query, %{data: "schedule-tomorrow"} = callback_query}, context) do
    tomorrow = DateTime.utc_now() |> Utils.start_of_next_day()

    reply_callback(context, callback_query, tomorrow, @tommorow_no_lessons)
  end

  def handle({:callback_query, %{data: "schedule-date-" <> date} = callback_query}, context) do
    {:ok, datetime, _offset} = DateTime.from_iso8601(date, :basic)

    reply_callback(context, callback_query, datetime)
  end

  def handle(:date, {:text, text, _message}, context) do
    case Utils.parse_russian_date(text) do
      {:ok, datetime} -> reply_message(context, datetime)
      :error -> answer(context, @parse_error)
    end
  end

  def reply_callback(context, callback_query, datetime, no_lessons_message \\ :auto) do
    response = reply_with(context, datetime, no_lessons_message)

    context
    |> answer_callback(callback_query)
    |> edit(:inline, response, parse_mode: "MarkdownV2", reply_markup: keyboard_next(datetime))
  end

  def reply_message(context, datetime) do
    response = reply_with(context, datetime, :auto)

    context
    |> answer(response, parse_mode: "MarkdownV2", reply_markup: keyboard_next(datetime))
  end

  defp reply_with(context, datetime, no_lessons_message) do
    user = context.extra.user

    formatted_date =
      datetime
      |> DateTime.shift_zone!("Asia/Yekaterinburg")
      |> Calendar.strftime("%A, %d %B",
        day_of_week_names: &Utils.weekday_to_russian/1,
        month_names: &Utils.month_to_russian/1
      )

    case get_response(user, datetime) do
      {:ok, []} ->
        case no_lessons_message do
          :auto -> "#{formatted_date}\n\n#{@no_lessons}"
          str -> str
        end

      {:ok, events} ->
        "#{formatted_date}\n\n#{format_events(events, datetime)}"

      {:error, reason} ->
        "#{formatted_date}\n\n#{reason}"
    end
  end

  def get_response(user, date) do
    with {:auth, {:ok, auth}} <- {:auth, Modeus.Auth.auth_user(user)},
         {:api, {:ok, response}} <- {:api, Modeus.Schedule.get_schedule_by_day(auth, date)} do
      {:ok, response}
    else
      {:auth, _} -> {:error, "Ошибка авторизации"}
      {:api, _} -> {:error, "Не удалось получить расписание"}
    end
  end

  @spec format_events([Event.t()], DateTime.t()) :: String.t()
  def format_events(events, now)

  def format_events([], _now), do: ""

  def format_events([event | events], now) do
    IO.inspect({event, now})
    status =
      cond do
        Event.impending?(event, now) ->
          "*Скоро начнётся:*\n"

        Event.ongoing?(event, now) ->
          "*Сейчас идёт:*\n"

        true ->
          ""
      end

    "#{status}#{Event.to_string(event)}\n\n#{format_events(events, now)}"
  end
end
