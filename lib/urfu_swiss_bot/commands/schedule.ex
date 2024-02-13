defmodule UrfuSwissBot.Commands.Schedule do
  @moduledoc false
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.InlineKeyboardMarkup
  alias ExGram.Model.Message
  alias UrfuApi.Modeus
  alias UrfuApi.Modeus.Schedule.ScheduleData
  alias UrfuSwissBot.Commands.Schedule.Formatter
  alias UrfuSwissKnife.Accounts
  alias UrfuSwissKnife.Modeus
  alias UrfuSwissKnife.Utils

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
                       button("Сегодня⬇️", callback_data: "Schedule.today")
                       button("Завтра➡️", callback_data: "Schedule.tomorrow")
                     end

                     row do
                       button("Меню", callback_data: "menu")
                     end
                   end)

  @spec keyboard_next(DateTime.t()) :: InlineKeyboardMarkup.t()
  defp keyboard_next(datetime) do
    previous_day =
      datetime
      |> Utils.to_yekaterinburg_zone()
      |> Utils.start_of_previous_day()
      |> DateTime.to_iso8601(:basic)

    next_day =
      datetime
      |> Utils.to_yekaterinburg_zone()
      |> Utils.start_of_next_day()
      |> DateTime.to_iso8601(:basic)

    keyboard :inline do
      row do
        button("⬅️", callback_data: "Schedule.date:#{previous_day}")
        button("Сегодня", callback_data: "Schedule.today")
        button("➡️", callback_data: "Schedule.date:#{next_day}")
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
  def handle({:callback_query, %{data: "Schedule"} = callback_query}, context) do
    Accounts.set_sending_schedule_date_state(context.extra.user)

    context
    |> answer_callback(callback_query)
    |> edit(:inline, @start_text, reply_markup: @start_keyboard)
  end

  def handle({:callback_query, %{data: "Schedule.today"}}, context) do
    now = DateTime.utc_now(:second)

    generic_answer(context, now, @today_no_more_events, true)
  end

  def handle({:callback_query, %{data: "Schedule.tomorrow"}}, context) do
    today = DateTime.utc_now(:second)

    tomorrow =
      today
      |> Utils.yekaterinburg_start_of_day()
      |> Utils.start_of_next_day()

    generic_answer(context, tomorrow, @tommorow_no_events)
  end

  def handle({:callback_query, %{data: "Schedule.date:" <> date}}, context) do
    {:ok, date, _offset} = DateTime.from_iso8601(date, :basic)

    generic_answer(context, date, @no_events)
  end

  @spec handle({:text, String.t(), Message}, Cnt.t()) :: Cnt.t()
  def handle({:text, text, _message}, context) do
    case Utils.parse_russian_date(text) do
      {:ok, date} ->
        generic_answer(context, date, @no_events)

      :error ->
        answer(context, @parse_error)
    end
  end

  @spec generic_answer(Cnt.t(), DateTime.t(), String.t(), boolean()) :: Cnt.t()
  defp generic_answer(context, date, no_events_message, today? \\ false) do
    %{extra: %{user: user}} = context

    case Modeus.auth_user(user) do
      {:ok, auth} ->
        local_time = Utils.yekaterinburg_start_of_day(date)

        not_filtered_schedule = Modeus.get_schedule_by_day(auth, local_time)

        schedule =
          if today? do
            reject_passed_events(not_filtered_schedule, date)
          else
            not_filtered_schedule
          end

        response =
          case schedule do
            %ScheduleData{events: []} -> Modeus.get_upcoming_schedule(auth, local_time)
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

  @spec reject_passed_events(term(), DateTime.t()) :: term()
  defp reject_passed_events(%ScheduleData{events: events} = schedule, now) do
    future_events =
      Enum.reject(events, fn %ScheduleData.Event{ends_at: ends_at} ->
        DateTime.after?(now, ends_at)
      end)

    %{schedule | events: future_events}
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
        %DateTime{} -> Utils.to_yekaterinburg_zone(date)
      end

    date_with_timezone
    |> Calendar.strftime("%A, %d %B",
      day_of_week_names: &Utils.weekday_to_russian/1,
      month_names: &Utils.month_to_russian/1
    )
    |> Utils.escape_telegram_markdown()
  end
end
