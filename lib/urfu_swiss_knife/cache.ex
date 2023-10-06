defmodule UrFUSwissKnife.Cache do
  use Nebulex.Cache,
    otp_app: :urfu_swiss_knife,
    adapter: Nebulex.Adapters.Local
end
