defmodule UrFUAPI.IStudent.Auth.API do
  alias UrFUAPI.AuthHelpers
  alias UrFUAPI.IStudent.Auth.Client
  alias UrFUAPI.IStudent.Auth.Token

  @url "https://sso.urfu.ru/adfs/OAuth2/authorize?resource=https%3A%2F%2Fistudent.urfu.ru&type=web_server&client_id=https%3A%2F%2Fistudent.urfu.ru&redirect_uri=https%3A%2F%2Fistudent.urfu.ru%3Fauth&response_type=code&scope="

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, String.t()}
  def sign_in(username, password) do
    case get_auth_tokens(username, password) do
      {:ok, auth_tokens} ->
        token =
          auth_tokens
          |> get_auth_url()
          |> get_access_token()

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

  @spec get_access_token(String.t()) :: Token.t()
  defp get_access_token(url) do
    response = Client.get!(url)

    response
    |> AuthHelpers.fetch_cookie!()
    |> Token.new()
  end
end
