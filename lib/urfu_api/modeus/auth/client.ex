defmodule UrFUAPI.Modeus.Auth.Client do
  use Tesla

  plug Tesla.Middleware.FormUrlencoded
end
