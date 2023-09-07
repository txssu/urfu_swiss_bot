defmodule UrFUSwissBot.Bot.StartCommand do
  alias UrFUSwissBot.Repo.User

  import ExGram.Dsl
  require ExGram.Dsl

  @start_text """
  Привет! Чтобы пользоваться ботом нужна авторизация. \
  Для этого отправьте логин и пароль от аккаунта УрФУ. Пример:
  ivan.ivanov@mail.ru
  123456qwerty
  """

  def handle({:command, :start, message}, context) do
    message.from.id
    |> User.new({UrFUSwissBot.Bot.Auth, :auth})
    |> User.save()

    answer(context, @start_text)
  end
end
