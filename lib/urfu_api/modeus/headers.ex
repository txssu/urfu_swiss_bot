defmodule UrFUAPI.Modeus.Headers do
  alias UrFUAPI.Modeus.Auth.Token

  @spec from_token(Token.t()) :: [{:headers, [{String.t(), String.t()}]}]
  def from_token(%Token{id_token: id_token}) do
    [headers: [{"Authorization", "Bearer #{id_token}"}]]
  end
end
