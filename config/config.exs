import Config

config :urfu_swiss_knife, UrFUSwissKnife.Cache,
  backend: :shards,
  gc_interval: :timer.hours(12),
  max_size: 1_000_000,
  allocated_memory: 2_000_000_000,
  gc_cleanup_min_timeout: :timer.seconds(10),
  gc_cleanup_max_timeout: :timer.minutes(10)

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

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :urfu_swiss_knife, UrFUSwissBot.Repo, database_folder: System.get_env("DATABASE_FOLDER", ".db")

import_config "#{config_env()}.exs"
