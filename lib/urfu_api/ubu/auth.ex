defmodule UrFUAPI.UBU.Auth do
  alias UrFUAPI.AuthHelpers
  alias UrFUAPI.UBU.Auth.Token

  defmodule Client do
    use Tesla

    plug Tesla.Middleware.FormUrlencoded
  end

  defmodule ClientJSON do
    use Tesla

    plug Tesla.Middleware.JSON
  end

  @url "https://sts.urfu.ru/adfs/OAuth2/authorize?client_id=https%3A%2F%2Fubu.urfu.ru%2Ffse&redirect_uri=https%3A%2F%2Fubu.urfu.ru%2Ffse&resource=https%3A%2F%2Fubu.urfu.ru%2Ffse&response_type=code&state=e30"
  @ubu_rpc "https://ubu.urfu.ru/fse/api/rpc"

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, String.t()}
  def sign_in(username, password) do
    case get_auth_tokens(username, password) do
      {:ok, auth_tokens} ->
        token =
          auth_tokens
          |> get_auth_url()
          |> get_ubu_login_code()
          |> get_access_token(username)

        {:ok, token}

      err ->
        err
    end
  end

  @spec get_auth_tokens(String.t(), String.t()) :: {:ok, [String.t()]} | {:error, String.t()}
  defp get_auth_tokens(username, password) do
    body = %{
      "UserName" => username,
      "Password" => password,
      "AuthMethod" => "FormsAuthentication"
    }

    response = Client.post!(@url, body)

    case AuthHelpers.ensure_redirect(response) do
      :error -> {:error, "Wrong credentials"}
      {:ok, response} -> {:ok, AuthHelpers.fetch_cookies!(response)}
    end
  end

  @spec get_auth_url([String.t()]) :: String.t()
  defp get_auth_url(tokens) do
    cookies = Enum.join(tokens, ";")

    response = Client.get!(@url, headers: [cookie: cookies])

    AuthHelpers.fetch_location!(response)
  end

  @spec get_ubu_login_code(String.t()) :: String.t()
  defp get_ubu_login_code(url) do
    response = Client.get!(url)

    parse_ubu_code(response)
  end

  @spec parse_ubu_code(Tesla.Env.t()) :: String.t()
  defp parse_ubu_code(response) do
    url = AuthHelpers.fetch_location!(response)
    %{query: query} = URI.parse(url)

    query
    |> URI.query_decoder()
    |> Enum.into(%{})
    |> Map.fetch!("code")
  end

  @spec get_access_token(String.t(), String.t()) :: Token.t()
  defp get_access_token(login_code, username) do
    body = %{
      method: "User.Login",
      params: %{
        code: login_code
      }
    }

    response = ClientJSON.post!(@ubu_rpc, body)

    response
    |> AuthHelpers.fetch_cookie!()
    |> Token.new(username)
  end
end
