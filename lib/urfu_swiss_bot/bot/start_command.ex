defmodule UrFUSwissBot.Bot.StartCommand do
  alias UrFUSwissBot.Repo.User

  import ExGram.Dsl
  require ExGram.Dsl

  @start_text """
  Чтобы пользоваться ботом необходима авторизация. \
  Для этого отправьте логин и пароль от аккаунта УрФУ.
  Пример:
  ivan.ivanov@mail.ru
  123456qwerty
  """

  @again_text """
  Похоже, что-то пошло не так! Чтобы продолжить пользоваться ботом \
  вам необходимо повторно авторизироваться. \
  Для этого отправьте логин и пароль от аккаунта УрФУ.
  Пример:
  ivan.ivanov@mail.ru
  123456qwerty
  """

  def handle({:command, :start, %{from: %{id: user_id}}}, context) do
    start_auth(context, user_id, @start_text)
  end

  def handle({:command, _command, %{from: %{id: user_id}}}, context) do
    start_auth(context, user_id)
  end

  def handle({:text, _text, %{from: %{id: user_id}}}, context) do
    start_auth(context, user_id)
  end

  def handle({:callback_query, %{from: %{id: user_id}} = callback_query}, context) do
    context
    |> answer_callback(callback_query)
    |> start_auth(user_id)
  end

  def start_auth(context, user_id, text \\ @again_text) do
    user_id
    |> User.new({UrFUSwissBot.Bot.Auth, :auth})
    |> User.save()

    answer(context, text)
  end
end
