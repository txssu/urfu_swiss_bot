import Config

config :logger, level: :info

config :urfu_swiss_knife, UrFUSwissKnife.Scheduler,
  timezone: "Asia/Yekaterinburg",
  jobs: [
    # After rebooting.
    {"@reboot", {UrFUSwissKnife.CacheWarming, :warm_all, []}},
    # At 00:00 on every day-of-week from Monday through Saturday.
    {"0 0 * * 1-6", {UrFUSwissKnife.CacheWarming, :warm_today_schedule, []}},
    # At minute 0 past every 4th hour from 8 through 20.
    {"0 8-20/4 * * *", {UrFUSwissKnife.CacheWarming, :warm_ubu_dates, []}},
    # At every 15th minute.
    {"*/15 * * * *", {UrFUSwissKnife.CacheWarming, :warm_istudent_brs, []}}
  ]
