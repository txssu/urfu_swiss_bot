defmodule UrFUAPI.Modeus.Auth.API do
  alias UrFUAPI.AuthHelpers
  alias UrFUAPI.Modeus.Auth.Client
  alias UrFUAPI.Modeus.Auth.Token

  defmodule AuthProcess do
    defstruct ~w[relay_url relay_state saml_tokens saml_response]a

    @type t :: %__MODULE__{
            relay_url: String.t() | nil,
            relay_state: String.t() | nil,
            saml_tokens: [String.t()] | nil,
            saml_response: String.t() | nil
          }

    @spec new :: t()
    def new, do: %__MODULE__{}
  end

  @oauth2 "https://urfu-auth.modeus.org/oauth2/authorize?response_type=id_token%20token&client_id=3CuF3FsNyRLiFVj0Il2fIujftw0a&state=Ym1KVy5NWDBXeXhRaU9qUk5HVW1Wb0Z-MVFadmo0c2VNYm9aWlh1OFc2bkxr&redirect_uri=https%3A%2F%2Furfu.modeus.org%2Fschedule-calendar%2Fmy&scope=openid&nonce=0"
  @common_auth "https://urfu-auth.modeus.org/commonauth"

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, any()}
  def sign_in(username, password) do
    process =
      AuthProcess.new()
      |> get_relay_data()
      |> get_saml_tokens(username, password)

    case process do
      {:ok, process} ->
        token =
          process
          |> get_saml_response()
          |> get_id_token()

        {:ok, token}

      err ->
        err
    end
  end

  @spec get_relay_data(AuthProcess.t()) :: AuthProcess.t()
  def get_relay_data(%AuthProcess{} = process) do
    response = Client.get!(@oauth2)

    response
    |> AuthHelpers.fetch_location!()
    |> insert_relay_data(process)
  end

  @spec insert_relay_data(String.t(), AuthProcess.t()) :: AuthProcess.t()
  defp insert_relay_data(relay_url, %AuthProcess{} = process) do
    process
    |> Map.put(:relay_url, relay_url)
    |> Map.put(:relay_state, fetch_relay_state(relay_url))
  end

  @spec fetch_relay_state(String.t()) :: String.t()
  defp fetch_relay_state(relay_url) do
    relay_url
    |> URI.parse()
    |> Map.fetch!(:query)
    |> URI.decode_query()
    |> Map.fetch!("RelayState")
  end

  @spec get_saml_tokens(AuthProcess.t(), String.t(), String.t()) ::
          {:ok, AuthProcess.t()} | {:error, any()}
  def get_saml_tokens(%AuthProcess{relay_url: url} = process, username, password) do
    body = %{
      "UserName" => username,
      "Password" => password,
      "AuthMethod" => "FormsAuthentication"
    }

    response = Client.post!(url, body)

    case AuthHelpers.ensure_redirect(response) do
      {:ok, response} ->
        process =
          response
          |> AuthHelpers.fetch_cookies!()
          |> insert_saml_tokens(process)

        {:ok, process}

      :error ->
        {:error, "Wrong credentials"}
    end
  end

  @spec insert_saml_tokens([String.t()], AuthProcess.t()) :: AuthProcess.t()
  defp insert_saml_tokens(saml_tokens, %AuthProcess{} = process) do
    Map.put(process, :saml_tokens, saml_tokens)
  end

  @spec get_saml_response(AuthProcess.t()) :: AuthProcess.t()
  def get_saml_response(%AuthProcess{relay_url: url, saml_tokens: tokens} = process) do
    response = Client.get!(url, headers: [{"cookie", Enum.join(tokens, ";")}])

    response
    |> parse_saml_response()
    |> insert_saml_response(process)
  end

  @spec insert_saml_response(String.t(), AuthProcess.t()) :: AuthProcess.t()
  defp insert_saml_response(saml_response, %AuthProcess{} = process) do
    Map.put(process, :saml_response, saml_response)
  end

  @spec parse_saml_response(Tesla.Env.t()) :: String.t()
  defp parse_saml_response(%Tesla.Env{body: body}) do
    body
    |> Floki.parse_document!()
    |> Floki.attribute("input[name=SAMLResponse]", "value")
    |> List.first()
  end

  @spec get_id_token(AuthProcess.t()) :: map()
  def get_id_token(process) do
    process
    |> get_auth_url()
    |> parse_auth_url()
    |> Token.new()
  end

  @spec get_auth_url(AuthProcess.t()) :: String.t()
  defp get_auth_url(%AuthProcess{saml_response: saml_response, relay_state: relay_state}) do
    body = %{
      "SAMLResponse" => saml_response,
      "RelayState" => relay_state
    }

    response = Client.post!(@common_auth, body)

    response
    |> AuthHelpers.fetch_location!()
    |> Client.get!()
    |> AuthHelpers.fetch_location!()
  end

  @spec parse_auth_url(String.t()) :: %{optional(binary) => binary}
  defp parse_auth_url("#" <> data) do
    URI.decode_query(data)
  end

  defp parse_auth_url(<<_ignored::utf8, rest::binary>>) do
    parse_auth_url(rest)
  end
end
