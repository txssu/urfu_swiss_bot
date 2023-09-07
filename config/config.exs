import Config

config :tesla, adapter: Tesla.Adapter.Hackney

config :urfu_swiss_bot, UrFUSwissBot.Cache,
  backend: :shards,
  gc_interval: :timer.hours(12),
  max_size: 1_000_000,
  allocated_memory: 2_000_000_000,
  gc_cleanup_min_timeout: :timer.seconds(10),
  gc_cleanup_max_timeout: :timer.minutes(10)

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase
