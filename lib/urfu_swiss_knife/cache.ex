defmodule UrfuSwissKnife.Cache do
  @moduledoc false
  use Nebulex.Cache,
    otp_app: :urfu_swiss_knife,
    adapter: Nebulex.Adapters.Local
end
