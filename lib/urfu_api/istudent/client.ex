defmodule UrFUAPI.IStudent.Client do
  alias UrFUAPI.IStudent.Auth.Token

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://istudent.urfu.ru/s/http-urfu-ru-ru-students-study-brs"

  @spec headers_from_token(Token.t()) :: [{:headers, [{String.t(), String.t()}]}]
  def headers_from_token(%{access_token: token}) do
    [headers: [{"cookie", token}]]
  end
end
