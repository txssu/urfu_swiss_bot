defmodule UrFUAPI.IStudent.Auth.Client do
  use Tesla

  plug Tesla.Middleware.FormUrlencoded
end
