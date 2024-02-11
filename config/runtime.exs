import Config
import SecretVault, only: [runtime_secret!: 2]

config :urfu_swiss_knife, UrfuSwissBot.Bot, token: runtime_secret!(:urfu_swiss_knife, "telegram_token")
