defmodule UrFUSwissBot.Bot.Schedule do
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.InlineKeyboardMarkup
  alias ExGram.Model.Message

  alias UrFUAPI.Modeus
  alias UrFUAPI.Modeus.Auth.Token

  alias UrFUAPI.Modeus.Schedule.ScheduleData

  alias UrFUSwissBot.Modeus
  alias UrFUSwissBot.Repo.User
  alias UrFUSwissBot.Utils

  alias UrFUSwissBot.Bot.Schedule.Formatter

  require ExGram.Dsl
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

  @no_events Utils.escape_telegram_markdown("""
             В этот день пар нет.\
             """)

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

  @spec keyboard_next(DateTime.t()) :: InlineKeyboardMarkup.t()
  def keyboard_next(datetime) do
    previous_day =
      datetime
      |> Utils.start_of_previous_day()
      |> DateTime.to_iso8601(:basic)

    next_day =
      datetime
      |> Utils.start_of_next_day()
      |> DateTime.to_iso8601(:basic)

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

  @spec handle(
          {:callback_query, CallbackQuery.t()},
          Cnt.t()
        ) :: Cnt.t()
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
    tomorrow = Utils.start_of_next_day(DateTime.utc_now())

    reply_callback(context, callback_query, tomorrow, @tommorow_no_events)
  end

  def handle({:callback_query, %{data: "schedule-date-" <> date} = callback_query}, context) do
    {:ok, datetime, _offset} = DateTime.from_iso8601(date, :basic)

    reply_callback(context, callback_query, datetime)
  end

  @spec handle(:date, {:text, String.t(), Message}, Cnt.t()) :: Cnt.t()
  def handle(:date, {:text, text, _message}, context) do
    case Utils.parse_russian_date(text) do
      {:ok, datetime} -> reply_message(context, datetime)
      :error -> answer(context, @parse_error)
    end
  end

  @spec reply_callback(Cnt.t(), CallbackQuery.t(), DateTime.t(), :auto | String.t()) :: Cnt.t()
  def reply_callback(context, callback_query, datetime, no_events_message \\ :auto) do
    response = reply_with(context, datetime, no_events_message)

    context
    |> answer_callback(callback_query)
    |> edit(:inline, response, parse_mode: "MarkdownV2", reply_markup: keyboard_next(datetime))
  end

  @spec reply_message(Cnt.t(), DateTime.t()) :: Cnt.t()
  def reply_message(context, datetime) do
    response = reply_with(context, datetime, :auto)

    answer(context, response, parse_mode: "MarkdownV2", reply_markup: keyboard_next(datetime))
  end

  @spec reply_with(Cnt.t(), DateTime.t(), :auto | String.t()) :: String.t()
  defp reply_with(context, datetime, no_events_message) do
    user = context.extra.user

    formatted_date = format_date(datetime)

    no_events_message =
      if no_events_message == :auto do
        @no_events
      else
        Utils.escape_telegram_markdown(no_events_message)
      end

    case get_response(user, datetime) do
      {:ok, :empty} ->
        "*#{formatted_date}*\n\n#{no_events_message}"

      {:ok, {next_date, schedule}} ->
        formatted_next_date = format_date(next_date)
        formatted_events = Formatter.format_events(schedule, datetime)

        """
        *#{formatted_date}*

        #{no_events_message}

        Вот расписание на ближайший день c парами:

        *#{formatted_next_date}*

        #{formatted_events}
        """

      {:ok, schedule} ->
        formatted_events = Formatter.format_events(schedule, datetime)
        "*#{formatted_date}*\n\n#{formatted_events}"

      {:error, reason} ->
        reason = Utils.escape_telegram_markdown(reason)
        "*#{formatted_date}*\n\n#{reason}"
    end
  end

  @spec get_response(User.t(), DateTime.t()) ::
          {:ok, :empty}
          | {:ok, {Date.t(), ScheduleData.t()}}
          | {:ok, ScheduleData.t()}
          | {:error, String.t()}
  defp get_response(user, datetime) do
    case Modeus.auth_user(user) do
      {:ok, auth} -> {:ok, get_schedule(auth, datetime)}
      {:error, _reason} -> {:error, "Ошибка авторизации"}
    end
  end

  @spec get_schedule(Token.t(), DateTime.t()) ::
          ScheduleData.t() | {Date.t(), ScheduleData.t()} | :empty
  defp get_schedule(auth, datetime) do
    with :empty <- get_schedule_by_day(auth, datetime),
         :empty <- get_upcoming_schedule(auth, datetime) do
      :empty
    else
      schedule -> schedule
    end
  end

  @spec get_schedule_by_day(Token.t(), DateTime.t()) :: ScheduleData.t() | :empty
  defp get_schedule_by_day(auth, datetime) do
    case Modeus.get_schedule_by_day(auth, datetime) do
      %ScheduleData{events: []} -> :empty
      %ScheduleData{} = schedule -> schedule
    end
  end

  @spec get_upcoming_schedule(Token.t(), DateTime.t()) :: {Date.t(), ScheduleData.t()} | :empty
  defp get_upcoming_schedule(auth, datetime) do
    case Modeus.get_upcoming_schedule(auth, datetime) do
      :empty -> :empty
      {%Date{}, %ScheduleData{}} = result -> result
    end
  end

  @spec format_date(Date.t() | DateTime.t()) :: String.t()
  defp format_date(date) do
    date_with_timezone =
      case date do
        %Date{} -> date
        %DateTime{} -> DateTime.shift_zone!(date, "Asia/Yekaterinburg")
      end

    date_with_timezone
    |> Calendar.strftime("%A, %d %B",
      day_of_week_names: &Utils.weekday_to_russian/1,
      month_names: &Utils.month_to_russian/1
    )
    |> Utils.escape_telegram_markdown()
  end
end
