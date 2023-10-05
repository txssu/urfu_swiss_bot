import Config

if System.get_env("NO_LOG") do
  config :logger, level: :none
end
