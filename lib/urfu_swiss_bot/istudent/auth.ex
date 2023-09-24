defmodule UrFUSwissBot.IStudent.Auth do
  alias UrFUSwissBot.Cache
  use Tesla
  use Nebulex.Caching

  plug Tesla.Middleware.FormUrlencoded

  @url "https://sts.urfu.ru/adfs/OAuth2/authorize?resource=https%3A%2F%2Fistudent.urfu.ru&type=web_server&client_id=https%3A%2F%2Fistudent.urfu.ru&redirect_uri=https%3A%2F%2Fistudent.urfu.ru%3Fauth&response_type=code&scope="

  @decorate cacheable(cache: Cache, key: {username, password})
  def auth(username, password) do
    send_username_and_password(username, password)
    |> resend_with_cookie()
    |> send_result_to_istudent()
    |> fetch_auth_cookie()
  end

  defp send_username_and_password(username, password) do
    body = %{
      "UserName" => username,
      "Password" => password,
      "AuthMethod" => "FormsAuthentication"
    }

    post!(@url, body)
  end

  defp resend_with_cookie(env) do
    url = Tesla.get_header(env, "location")
    token = Tesla.get_header(env, "set-cookie")

    get!(url, headers: [{"cookie", token}])
  end

  defp send_result_to_istudent(env) do
    url = Tesla.get_header(env, "location")

    get!(url)
  end

  defp fetch_auth_cookie(env) do
    Tesla.get_header(env, "set-cookie")
  end
end
