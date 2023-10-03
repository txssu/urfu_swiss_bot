defmodule UrFUSwissBot.Bot.StartCommand do
  import ExGram.Dsl

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.Message

  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.Accounts.User

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

  @instruction """

  Для этого отправьте логин и пароль от аккаунта УрФУ.
  Пример:
  ivan.ivanov@mail.ru
  123456qwerty
  """

  # Start auth for new user
  @spec handle(
          {:callback_query, CallbackQuery.t()}
          | {:command, atom(), Message.t()}
          | {:text, String.t(), Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle({:command, :start, %{from: %{id: user_id}}}, context) do
    start_auth_new_user(context, user_id)
  end

  # If database is lost it need to handle others actions and start auth
  def handle(event, %Cnt{extra: %{user: nil}} = context) do
    case event do
      {type, _body, message} when type in [:text, :command] ->
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
    answered_context =
      case event do
        {:command, _command, _message} ->
          context

        {:callback_query, callback_query} ->
          answer_callback(context, callback_query)
      end

    continue_auth(answered_context)
  end

  @spec start_auth_new_user(Cnt.t(), integer()) :: Cnt.t()
  def start_auth_new_user(context, user_id) do
    context
    |> set_auth_state(Accounts.create_user(user_id))
    |> answer_message_auth(@start_text)
  end

  @spec again_auth(Cnt.t(), integer()) :: Cnt.t()
  def again_auth(context, user_id) do
    context
    |> set_auth_state(Accounts.create_user(user_id))
    |> answer_message_auth(@again_text)
  end

  @spec continue_auth(Cnt.t()) :: Cnt.t()
  def continue_auth(context) do
    answer_message_auth(context, @continue_text)
  end

  @spec reauth(Cnt.t(), User.t(), CallbackQuery.t()) :: Cnt.t()
  def reauth(context, user, callback) do
    context
    |> set_auth_state(user)
    |> answer_callback_auth(callback, @reauth_text)
  end

  @spec set_auth_state(Cnt.t(), User.t()) :: Cnt.t()
  defp set_auth_state(context, user) do
    user
    |> User.delete_credentials()
    |> User.set_state({UrFUSwissBot.Bot.Auth, :auth})
    |> Accounts.save_user()

    context
  end

  @spec answer_message_auth(Cnt.t(), String.t()) :: Cnt.t()
  defp answer_message_auth(context, text), do: answer(context, text <> @instruction)

  @spec answer_callback_auth(Cnt.t(), CallbackQuery.t(), String.t()) :: Cnt.t()
  defp answer_callback_auth(context, callback, text) do
    context
    |> answer_callback(callback)
    |> edit(:inline, text <> @instruction)
  end
end
