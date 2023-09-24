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

config :urfu_swiss_bot, UrFUSwissBot.Repo,
  database_folder: System.get_env("DATABASE_FOLDER", ".db")

config :urfu_swiss_bot, :secret_vault,
  default: [password: System.fetch_env!("SECRET_VAULT_PASSWORD")]

config :floki, :html_parser, Floki.HTMLParser.FastHtml

config :urfu_swiss_bot, UrFUSwissBot.Scheduler,
  jobs: [
    {"*/15 8-22 * *", {UrFUSwissBot.Bot.BRS, :update_users_brs, []}}
  ]

import_config "#{config_env()}.exs"
