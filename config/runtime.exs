import Config

disabled_in_test = config_env() != :test

config :urfu_swiss_knife, UrFUSwissBot.Bot,
  enabled: disabled_in_test,
  token: System.get_env("TELEGRAM_TOKEN")

config :urfu_swiss_knife, UrFUSwissKnife.Scheduler, enabled: disabled_in_test
