defmodule UrFUSwissBot.Cache do
  use Nebulex.Cache,
    otp_app: :urfu_swiss_bot,
    adapter: Nebulex.Adapters.Local
end
