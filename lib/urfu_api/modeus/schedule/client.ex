defmodule UrFUAPI.Modeus.Schedule.Client do
  alias UrFUAPI.Modeus.Auth.Token

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://urfu.modeus.org/schedule-calendar-v2/api"
  plug Tesla.Middleware.JSON

  @spec headers(Token.t()) :: [{:headers, [{String.t(), String.t()}]}]
  def headers(%Token{id_token: id_token}) do
    [headers: [{"Authorization", "Bearer #{id_token}"}]]
  end
end
