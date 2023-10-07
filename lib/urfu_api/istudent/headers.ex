defmodule UrFUAPI.Istudent.Headers do
  @spec from_token(Token.t()) :: [{:headers, [{String.t(), String.t()}]}]
  def from_token(%{access_token: token}) do
    [headers: [{"cookie", token}]]
  end
end
