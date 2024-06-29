import Config

config :urfu_swiss_knife, UrFUSwissKnife.Cache,
  backend: :shards,
  gc_interval: :timer.hours(12),
  max_size: 1_000_000,
  allocated_memory: 2_000_000_000,
  gc_cleanup_min_timeout: :timer.seconds(10),
  gc_cleanup_max_timeout: :timer.minutes(10)

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :urfu_swiss_knife, UrFUSwissBot.Repo, database_folder: System.get_env("DATABASE_FOLDER", ".db")

import_config "#{config_env()}.exs"
