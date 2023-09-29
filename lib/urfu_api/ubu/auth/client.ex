defmodule UrFUAPI.UBU.Auth.Client do
  use Tesla

  defmodule JSON do
    use Tesla

    plug Tesla.Middleware.JSON
  end

  plug Tesla.Middleware.FormUrlencoded
end
