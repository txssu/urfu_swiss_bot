import Config

config :urfu_swiss_knife, UrFUSwissBot.Bot, token: System.fetch_env!("TELEGRAM_TOKEN")
