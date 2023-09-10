import Config
import SecretVault, only: [runtime_secret!: 2]

config :urfu_swiss_bot, UrFUSwissBot.Bot,
  token: runtime_secret!(:urfu_swiss_bot, "telegram_token")
