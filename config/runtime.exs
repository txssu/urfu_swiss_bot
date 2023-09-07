import Config

config :urfu_swiss_bot, UrFUSwissBot.Bot, token: System.get_env("TELEGRAM_TOKEN")

if config_env() == :prod do
  config :urfu_swiss_bot, UrFUSwissBot.Repo, database_folder: System.get_env("DATABASE_FOLDER")
end
