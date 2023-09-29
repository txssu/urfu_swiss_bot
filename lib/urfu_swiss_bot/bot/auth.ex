defmodule UrFUSwissBot.Bot.Auth do
  import ExGram.Dsl

  alias UrFUSwissBot.Bot.Menu
  alias UrFUSwissBot.Modeus
  alias UrFUSwissBot.Repo.User

  require ExGram.Dsl

  @auth_success "🎉🎊Авторизация прошла успешно🎉🎊"

  @wrong_credentials "Неверный логин или пароль❌"

  @parse_error """
  Неверный формат. Пожалуйста, используйте формат, представленный ниже:
  ЛОГИН
  ПАРОЛЬ

  Пример:
  ivan.ivanov@mail.ru
  123456qwerty
  """

  def handle(:auth, {:text, text, message}, context) do
    user = context.extra.user

    case String.split(text) do
      [username, password] ->
        user
        |> User.set_credentials(username, password)
        |> try_auth_user(message, context)

      _error ->
        answer(context, @parse_error)
    end
  end

  defp try_auth_user(user, message, context) do
    case Modeus.auth_user(user) do
      {:ok, _autj} ->
        user
        |> User.nil_state()
        |> User.save()

        context
        |> accepted(message, user.username)
        |> answer(@auth_success)
        |> Menu.menu_by_message()

      _error ->
        context
        |> accepted(message, user.username)
        |> answer(@wrong_credentials)
    end
  end

  defp accepted(context, message, username) do
    context
    |> delete(message)
    |> answer(message_deleted(username))
  end

  defp message_deleted(username) do
    email = hide_email(username)

    """
    Введённые данные:
    #{email}
    ********

    В целях безопасности ваще сообщение было удалено
    """
  end

  defp hide_email(email, result \\ "", visible_characters \\ 3)

  defp hide_email("@" <> _domain = domain, result, _visible_characters) do
    result <> domain
  end

  defp hide_email("", result, _visible_characters) do
    result
  end

  defp hide_email(<<_char::utf8, rest::binary>>, result, 0) do
    hide_email(rest, result <> "*", 0)
  end

  defp hide_email(<<char::utf8, rest::binary>>, result, visible_characters) do
    hide_email(rest, <<result::binary, char::utf8>>, visible_characters - 1)
  end
end
