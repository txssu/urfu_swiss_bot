defmodule UrFUSwissBot.Bot.Schedule do
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.InlineKeyboardMarkup
  alias ExGram.Model.Message

  alias UrFUAPI.Modeus
  alias UrFUAPI.Modeus.Schedule.ScheduleData

  alias UrFUSwissBot.Modeus
  alias UrFUSwissBot.Utils

  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.Accounts.User

  alias UrFUSwissBot.Bot.Schedule.Formatter

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  @start_text """
  Вы можете нажать кнопку, отправить день недели или дату.
  Вместо 25.09.2023 вы также можете написать 25.09 или просто 25
  """

  @today_no_more_events Utils.escape_telegram_markdown("""
                        Пары закончились. Пора отдыхать 😼\
                        """)

  @tommorow_no_events Utils.escape_telegram_markdown("""
                      Завтра нет пар. Можно отметить🥴\
                      """)

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
  defp keyboard_next(datetime) do
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
    |> Accounts.save_user()

    context
    |> answer_callback(callback_query)
    |> edit(:inline, @start_text, reply_markup: @start_keyboard)
  end

  def handle({:callback_query, %{data: "schedule-today"}}, context) do
    now = DateTime.utc_now()

    generic_answer(context, now, @today_no_more_events)
  end

  def handle({:callback_query, %{data: "schedule-tomorrow"}}, context) do
    tomorrow = Utils.start_of_next_day(DateTime.utc_now())

    generic_answer(context, tomorrow, @tommorow_no_events)
  end

  def handle({:callback_query, %{data: "schedule-date-" <> date}}, context) do
    {:ok, date, _offset} = DateTime.from_iso8601(date, :basic)

    generic_answer(context, date, @no_events)
  end

  @spec handle(:date, {:text, String.t(), Message}, Cnt.t()) :: Cnt.t()
  def handle(:date, {:text, text, _message}, context) do
    case Utils.parse_russian_date(text) do
      {:ok, date} ->
        generic_answer(context, date, @no_events)

      :error ->
        answer(context, @parse_error)
    end
  end

  @spec generic_answer(Cnt.t(), DateTime.t(), String.t()) :: Cnt.t()
  defp generic_answer(context, date, no_events_message) do
    %{extra: %{user: user}} = context

    case Modeus.auth_user(user) do
      {:ok, auth} ->
        response =
          case Modeus.get_schedule_by_day(auth, date) do
            %ScheduleData{events: []} -> Modeus.get_upcoming_schedule(auth, date)
            schedule -> schedule
          end

        response
        |> format_response(date, no_events_message)
        |> reply(date, context)

      {:error, reason} ->
        reason
        |> Utils.escape_telegram_markdown()
        |> reply(date, context)
    end
  end

  @spec reply(String.t(), DateTime.t(), Cnt.t()) :: Cnt.t()
  defp reply(text, datetime, context) do
    %{update: update} = context

    case update do
      %{message: %{}} ->
        answer(context, text,
          parse_mode: "MarkdownV2",
          reply_markup: keyboard_next(datetime)
        )

      %{callback_query: %{} = callback_query} ->
        context
        |> answer_callback(callback_query)
        |> edit(:inline, text,
          parse_mode: "MarkdownV2",
          reply_markup: keyboard_next(datetime)
        )
    end
  end

  @spec format_response(term(), DateTime.t(), String.t()) :: String.t()
  defp format_response(response, datetime, no_events_message)

  defp format_response({_date, %ScheduleData{events: []}}, datetime, no_events_message) do
    formatted_date = format_date(datetime)

    "*#{formatted_date}*\n\n#{no_events_message}"
  end

  defp format_response({next_date, schedule}, datetime, no_events_message) do
    formatted_date = format_date(datetime)
    formatted_next_date = format_date(next_date)

    formatted_events = Formatter.format_events(schedule, datetime)

    """
    *#{formatted_date}*

    #{no_events_message}

    Вот расписание на ближайший день c парами:

    *#{formatted_next_date}*

    #{formatted_events}
    """
  end

  defp format_response(schedule, datetime, _no_events_message) do
    formatted_date = format_date(datetime)

    formatted_events = Formatter.format_events(schedule, datetime)
    "*#{formatted_date}*\n\n#{formatted_events}"
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
