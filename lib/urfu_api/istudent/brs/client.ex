defmodule UrFUAPI.IStudent.BRS.Client do
  alias UrFUAPI.IStudent.Auth.Token

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://istudent.urfu.ru/s/http-urfu-ru-ru-students-study-brs"

  @spec headers(Token.t()) :: [{:headers, [{String.t(), String.t()}]}]
  def headers(%{access_token: token}) do
    [headers: [{"cookie", token}]]
  end
end
