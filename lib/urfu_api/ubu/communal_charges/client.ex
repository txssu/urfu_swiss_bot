defmodule UrFUAPI.UBU.CommunalCharges.Client do
  alias UrFUAPI.UBU.Auth.Token

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://ubu.urfu.ru/fse/api/rpc"
  plug Tesla.Middleware.JSON

  @spec exec(Token.t(), String.t()) :: Tesla.Env.t()
  def exec(auth, method_name) do
    body = %{
      method: method_name
    }

    post!("", body, headers(auth))
  end

  @spec headers(Token.t()) :: [{:headers, [{String.t(), String.t()}]}]
  def headers(%{access_token: token}) do
    [headers: [{"cookie", token}]]
  end
end
