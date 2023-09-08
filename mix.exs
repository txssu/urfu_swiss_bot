defmodule UrFUSwissBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :urfu_swiss_bot,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {UrFUSwissBot.Application, []}
    ]
  end

  defp deps do
    [
      # TimeZones database
      {:tzdata, "~> 1.1"},
      # Database
      {:cubdb, "~> 2.0.2"},
      # Telegram bot
      {:ex_gram, "~> 0.40.0"},
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:jason, ">= 1.0.0"},
      # JWT tokens
      {:joken, "~> 2.5"},
      # Nebulex
      {:nebulex, "~> 2.5"},
      {:shards, "~> 1.1"},
      {:decorator, "~> 1.4"},
      {:telemetry, "~> 1.0"},
      # Code quality
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:gradient, github: "esl/gradient", only: [:dev, :test], runtime: false},
      # Secret
      {:secret_vault, "~> 1.0"}
    ]
  end
end
