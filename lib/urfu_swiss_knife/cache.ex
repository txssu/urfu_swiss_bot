defmodule UrFUSwissKnife.Cache do
  @moduledoc false
  use Nebulex.Cache,
    otp_app: :urfu_swiss_knife,
    adapter: Application.compile_env(:urfu_swiss_knife, [__MODULE__, :adapter], Nebulex.Adapters.Local)
end
