defmodule UrFUAPI.UBU.Headers do
  alias UrFUAPI.UBU.Auth.Token

  @spec from_token(Token.t()) :: [{:headers, [{String.t(), String.t()}]}]
  def from_token(%Token{access_token: token}) do
    [headers: [{"cookie", token}]]
  end
end
