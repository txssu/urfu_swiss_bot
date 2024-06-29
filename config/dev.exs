import Config

if System.get_env("NO_LOG") do
  config :logger, level: :none
end

if System.get_env("NO_CACHE") do
  config :urfu_swiss_knife, UrFUSwissKnife.Cache, adapter: Nebulex.Adapters.Nil
end

config :urfu_swiss_knife, UrFUSwissKnife.Scheduler,
  timezone: "Asia/Yekaterinburg",
  jobs: [
    # After rebooting.
    {"@reboot", {UrFUSwissKnife.CacheWarming, :warm_all, []}}
  ]
