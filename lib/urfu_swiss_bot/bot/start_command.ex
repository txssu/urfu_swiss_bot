defmodule UrFUSwissBot.Bot.StartCommand do
  alias ExGram.Cnt
  alias UrFUSwissBot.Repo.User

  import ExGram.Dsl
  require ExGram.Dsl

  @start_text """
  Чтобы пользоваться ботом необходима авторизация.
  """

  @reauth_text """
  Теперь повторно пройдите авторизацию.
  """

  @continue_text """
  Сначала закончите авторизацию!
  """

  @again_text """
  Похоже, что-то пошло не так! Чтобы продолжить пользоваться ботом \
  вам необходимо повторно авторизироваться.
  """

  @host "http://localhost:4000"

  # Start auth for new user
  def handle({:command, :start, %{from: %{id: user_id}}}, context) do
    start_auth_new_user(context, user_id)
  end

  # If database is lost it need to handle others actions and start auth
  def handle(event, %Cnt{extra: %{user: nil}} = context) do
    case event do
      {type, _, message} when type in [:text, :command] ->
        again_auth(context, message.from.id)

      {:callback_query, callback_query} ->
        context
        |> answer_callback(callback_query)
        |> again_auth(callback_query.from.id)
    end
  end

  # User manual reauth
  def handle({:callback_query, %{data: "start-reauth"} = callback_query}, context) do
    reauth(context, context.extra.user, callback_query)
  end

  # Prevent others actions throught auth
  def handle(event, context) do
    case event do
      {:command, _command, _message} ->
        context

      {:callback_query, callback_query} ->
        answer_callback(context, callback_query)
    end
    |> continue_auth()
  end

  def start_auth_new_user(context, user_id) do
    context
    |> set_auth_state(User.new(user_id))
    |> answer_message_auth(@start_text, user_id)
  end

  def again_auth(context, user_id) do
    context
    |> set_auth_state(User.new(user_id))
    |> answer_message_auth(@again_text, user_id)
  end

  def continue_auth(context) do
    context
    |> answer_message_auth(@continue_text, context.extra.user.id)
  end

  def reauth(context, user, callback) do
    context
    |> set_auth_state(user)
    |> answer_callback_auth(callback, @reauth_text, user.id)
  end

  defp set_auth_state(context, user) do
    user
    |> User.delete_credentials()
    |> User.set_state({UrFUSwissBot.Bot.Auth, :auth})
    |> User.save()

    context
  end

  defp answer_message_auth(context, text, user_id) do
    answer(context, text <> instruction(user_id))
  end

  defp answer_callback_auth(context, callback, text, user_id) do
    context
    |> answer_callback(callback)
    |> edit(:inline, text <> instruction(user_id))
  end

  defp instruction(id) do
    """

    Чтобы это сделать вы можете отправить сюда сообщение с логином и паролем от личного \
    кабинету УрФУ:
    Ivan.Ivanov@mail.ru
    mysecretpassword123

    Или авторизоваться через ссылку:
    #{@host}/?telegram_id=#{id}
    """
  end
end
