defmodule UrFUSwissBot.Bot.Schedule do
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
  На сегодня пар не осталось 😼
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
    today = DateTime.now!("Asia/Yekaterinburg")

    reply_callback(context, callback_query, today, @today_no_more_lessons)
  end

  def handle({:callback_query, %{data: "schedule-tomorrow"} = callback_query}, context) do
    tomorrow = DateTime.now!("Asia/Yekaterinburg") |> Utils.start_of_next_day()

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
    |> edit(:inline, response, reply_markup: keyboard_next(datetime))
  end

  def reply_message(context, datetime) do
    response = reply_with(context, datetime, :auto)

    context
    |> answer(response, reply_markup: keyboard_next(datetime))
  end

  defp reply_with(context, datetime, no_lessons_message) do
    user = context.extra.user

    formatted_date =
      Calendar.strftime(datetime, "%A, %d %B",
        day_of_week_names: &Utils.weekday_to_russian/1,
        month_names: &Utils.month_to_russian/1
      )

    case get_response(user, datetime) do
      "" ->
        case no_lessons_message do
          :auto -> "#{formatted_date}\n\n#{@no_lessons}"
          str -> str
        end

      response ->
        "#{formatted_date}\n\n#{response}"
    end
  end

  def get_response(user, date) do
    with {:auth, {:ok, auth}} <- {:auth, Modeus.Auth.auth_user(user)},
         {:api, {:ok, response}} <- {:api, Modeus.Schedule.get_schedule_by_day(auth, date)} do
      response
    else
      {:auth, _} -> "Ошибка авторизации"
      {:api, _} -> "Не удалось получить расписание"
    end
  end
end
