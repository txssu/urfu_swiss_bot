defmodule UrFUSwissBot.Modeus.AuthAPI do
  use Tesla

  defstruct ~w[access_token expires person_id username]a

  @type t :: %__MODULE__{
          access_token: String.t(),
          expires: pos_integer,
          person_id: String.t(),
          username: String.t()
        }

  plug Tesla.Middleware.FormUrlencoded

  @oauth2 "https://urfu-auth.modeus.org/oauth2/authorize?response_type=id_token%20token&client_id=3CuF3FsNyRLiFVj0Il2fIujftw0a&state=Ym1KVy5NWDBXeXhRaU9qUk5HVW1Wb0Z-MVFadmo0c2VNYm9aWlh1OFc2bkxr&redirect_uri=https%3A%2F%2Furfu.modeus.org%2Fschedule-calendar%2Fmy&scope=openid&nonce=0"
  @common_auth "https://urfu-auth.modeus.org/commonauth"

  @spec auth(String.t(), String.t()) :: {:ok, t} | {:error, any}
  def auth(username, password) do
    with {:ok, relay_url} <- get_relay_url(),
         relay_state = fetch_relay_state(relay_url),
         {:ok, token} <- get_saml_token(relay_url, username, password),
         {:ok, saml_response} <- get_saml_response(relay_url, token),
         {:ok, access_token} <- sign_in(saml_response, relay_state),
         {:ok, claims} <- peek_claims(access_token) do
      {:ok, new(access_token, claims)}
    else
      err -> err
    end
  end

  @spec get_relay_url :: {:ok, String.t()} | {:error, any}
  def get_relay_url do
    case get(@oauth2) do
      {:ok, response} -> {:ok, Tesla.get_header(response, "location")}
      err -> err
    end
  end

  @spec fetch_relay_state(String.t()) :: String.t()
  def fetch_relay_state(relay_url) do
    relay_url
    |> URI.parse()
    |> Map.fetch!(:query)
    |> URI.decode_query()
    |> Map.fetch!("RelayState")
  end

  @spec get_saml_token(String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, any}
  def get_saml_token(url, username, password) do
    body = %{
      "UserName" => username,
      "Password" => password,
      "AuthMethod" => "FormsAuthentication"
    }

    case post(url, body) do
      {:ok, response} -> {:ok, Tesla.get_header(response, "set-cookie")}
      err -> err
    end
  end

  @spec get_saml_response(String.t(), String.t()) :: {:ok, String.t()} | {:error, any}
  def get_saml_response(url, token) do
    case get(url, headers: [{"cookie", token}]) do
      {:ok, %{body: body}} -> {:ok, parse_saml_response(body)}
      err -> err
    end
  end

  @spec sign_in(String.t(), String.t()) :: {:ok, String.t()} | {:error, any}
  def sign_in(saml_response, relay_state) do
    body = %{
      "SAMLResponse" => saml_response,
      "RelayState" => relay_state
    }

    with {:ok, new_url_response} <- post(@common_auth, body),
         {:ok, response} <- get(Tesla.get_header(new_url_response, "location")),
         auth_url = Tesla.get_header(response, "location"),
         %{"id_token" => id_token} <- parse_auth_data(auth_url) do
      {:ok, id_token}
    else
      %{"error" => _} = err -> {:error, err}
      err -> err
    end
  end

  @spec peek_claims(String.t()) :: {:ok, map()} | {:error, :token_malformed}
  def peek_claims(token) do
    case Joken.peek_claims(token) do
      {:ok, _} = result -> result
      err -> err
    end
  end

  def new(access_token, %{
        "exp" => expires,
        "person_id" => person_id,
        "preferred_username" => username
      }) do
    %__MODULE__{
      access_token: access_token,
      expires: expires,
      person_id: person_id,
      username: username
    }
  end

  @spec parse_saml_response(String.t()) :: String.t()
  def parse_saml_response("value=\"" <> token) do
    parse_until(token, ?")
  end

  def parse_saml_response(<<_::utf8, rest::binary>>) do
    parse_saml_response(rest)
  end

  @spec parse_auth_data(String.t()) :: map
  def parse_auth_data("#" <> data) do
    data
    |> URI.decode_query()
  end

  def parse_auth_data(<<_::utf8, rest::binary>>) do
    parse_auth_data(rest)
  end

  defp parse_until(<<char::utf8, rest::binary>>, until_char, token \\ "") do
    if char == until_char,
      do: token,
      else: parse_until(rest, until_char, <<token::binary, char::utf8>>)
  end
end
