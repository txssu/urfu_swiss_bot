defmodule UrFUSwissBot.Bot.Schedule do
  alias UrFUAPI.Modeus.Schedule.ScheduleData

  alias UrFUSwissBot.Modeus
  alias UrFUSwissBot.Repo.User
  alias UrFUSwissBot.Utils

  alias UrFUSwissBot.Bot.Schedule.Formatter

  import ExGram.Dsl
  require ExGram.Dsl

  import ExGram.Dsl.Keyboard
  require ExGram.Dsl.Keyboard

  @start_text """
  Вы можете нажать кнопку, отправить день недели или дату.
  Вместо 25.09.2023 вы также можете написать 25.09 или просто 25
  """

  @today_no_more_events """
  Пары закончились. Пора отдыхать 😼\
  """

  @tommorow_no_events """
  Завтра нет пар. Можно отметить🥴\
  """

  @no_events """
  В этот день пар нет.\
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
        button("Сегодня", callback_data: "schedule-today")
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

    reply_callback(context, callback_query, today, @today_no_more_events)
  end

  def handle({:callback_query, %{data: "schedule-tomorrow"} = callback_query}, context) do
    tomorrow = DateTime.utc_now() |> Utils.start_of_next_day()

    reply_callback(context, callback_query, tomorrow, @tommorow_no_events)
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

  def reply_callback(context, callback_query, datetime, no_events_message \\ :auto) do
    response = reply_with(context, datetime, no_events_message)

    context
    |> answer_callback(callback_query)
    |> edit(:inline, response, parse_mode: "MarkdownV2", reply_markup: keyboard_next(datetime))
  end

  def reply_message(context, datetime) do
    response = reply_with(context, datetime, :auto)

    context
    |> answer(response, parse_mode: "MarkdownV2", reply_markup: keyboard_next(datetime))
  end

  defp reply_with(context, datetime, no_events_message) do
    user = context.extra.user

    formatted_date = format_date(datetime)

    no_events_message =
      case no_events_message do
        :auto -> @no_events
        str -> str
      end
      |> Utils.escape_telegram_markdown()

    case get_response(user, datetime) do
      {:ok, :empty} ->
        "*#{formatted_date}*\n\n#{no_events_message}"

      {:ok, {date, schedule}} ->
        """
        *#{formatted_date}*

        #{no_events_message}

        Вот расписание на ближайший день c парами:

        *#{format_date(date)}*

        #{Formatter.format_events(schedule, datetime)}
        """

      {:ok, schedule} ->
        "*#{formatted_date}*\n\n#{Formatter.format_events(schedule, datetime)}"

      {:error, reason} ->
        reason = Utils.escape_telegram_markdown(reason)
        "*#{formatted_date}*\n\n#{reason}"
    end
  end

  @spec get_response(User.t(), DateTime.t()) ::
          {:ok, :empty}
          | {:ok, {Date.t(), ScheduleData.t()}}
          | {:ok, ScheduleData.t()}
          | {:error, any}
  defp get_response(user, datetime) do
    case Modeus.auth_user(user) do
      {:ok, auth} -> {:ok, get_schedule(auth, datetime)}
      {:error, _reason} -> {:error, "Ошибка авторизации"}
    end
  end

  defp get_schedule(auth, datetime) do
    with :empty <- get_schedule_by_day(auth, datetime),
         :empty <- get_upcoming_schedule(auth, datetime) do
      :empty
    else
      schedule -> schedule
    end
  end

  defp get_schedule_by_day(auth, datetime) do
    case Modeus.get_schedule_by_day(auth, datetime) do
      %ScheduleData{events: []} -> :empty
      %ScheduleData{} = schedule -> schedule
    end
  end

  defp get_upcoming_schedule(auth, datetime) do
    case Modeus.get_upcoming_schedule(auth, datetime) do
      :empty -> :empty
      {%Date{}, %ScheduleData{}} = result -> result |> IO.inspect()
    end
  end

  defp format_date(date) do
    case date do
      %Date{} -> date
      %DateTime{} -> DateTime.shift_zone!(date, "Asia/Yekaterinburg")
    end
    |> Calendar.strftime("%A, %d %B",
      day_of_week_names: &Utils.weekday_to_russian/1,
      month_names: &Utils.month_to_russian/1
    )
    |> Utils.escape_telegram_markdown()
  end
end
