defmodule UrFUSwissBot.Bot.Auth do
  alias UrFUSwissBot.Bot.Menu
  alias UrFUSwissBot.Modeus
  alias UrFUSwissBot.Repo.User

  import ExGram.Dsl
  require ExGram.Dsl

  @auth_success "🎉🎊Вы авторизованы🎉🎊"

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
        case Modeus.Auth.register_user(user, username, password) do
          {:ok, _} ->
            user
            |> User.set_credentials(username, password)
            |> User.nil_state()
            |> User.save()

            context
            |> accepted(message, username)
            |> answer(@auth_success)
            |> Menu.redirect()

          _error ->
            context
            |> accepted(message, username)
            |> answer(@wrong_credentials)
        end

      _error ->
        answer(context, @parse_error)
    end
  end

  defp accepted(context, message, username) do
    context
    |> delete(message)
    |> answer(message_deleted(username))
  end

  defp message_deleted(username) do
    """
    Ваши данные:
    #{hide_email(username)}
    ********
    Приняты✅

    В целях безопасности ваще сообщение было удалено
    """
  end

  defp hide_email(email, result \\ "", visible_characters \\ 3)

  defp hide_email("@" <> _ = domain, result, _) do
    result <> domain
  end

  defp hide_email("", result, _) do
    result
  end

  defp hide_email(<<_::utf8, rest::binary>>, result, 0) do
    hide_email(rest, result <> "*", 0)
  end

  defp hide_email(<<char::utf8, rest::binary>>, result, visible_characters) do
    hide_email(rest, <<result::binary, char::utf8>>, visible_characters - 1)
  end
end
