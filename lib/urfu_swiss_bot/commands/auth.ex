defmodule UrFUSwissBot.Commands.Auth do
  import ExGram.Dsl

  alias ExGram.Cnt
  alias ExGram.Model.Message

  alias UrFUSwissBot.Commands.Menu
  alias UrFUSwissKnife.IStudent

  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.Accounts.User

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

  @spec handle({:text, String.t(), Message.t()}, Cnt.t()) :: Cnt.t()
  def handle({:text, text, message}, context) do
    user = context.extra.user

    case String.split(text) do
      [username, password] ->
        user
        |> Accounts.edit_user_credentials(username, password)
        |> try_auth_user(message, context)

      _error ->
        answer(context, @parse_error)
    end
  end

  @spec try_auth_user(User.t(), Message.t(), Cnt.t()) :: Cnt.t()
  defp try_auth_user(user, message, context) do
    case IStudent.auth_user(user) do
      {:ok, _autj} ->
        Accounts.remove_state(user)

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

  @spec accepted(Cnt.t(), Message.t(), String.t()) :: Cnt.t()
  defp accepted(context, message, username) do
    context
    |> delete(message)
    |> answer(message_deleted(username))
  end

  @spec message_deleted(String.t()) :: String.t()
  defp message_deleted(username) do
    email = hide_email(username)

    """
    Введённые данные:
    #{email}
    ********

    В целях безопасности ваще сообщение было удалено
    """
  end

  @spec hide_email(String.t(), String.t(), non_neg_integer()) :: String.t()
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
