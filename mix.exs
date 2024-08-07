defmodule UrFUSwissBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :urfu_swiss_knife,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {UrFUSwissKnife.Application, []}
    ]
  end

  defp deps do
    [
      # TimeZones database
      {:tzdata, "~> 1.1"},
      # Database
      {:cubdb, "~> 2.0.2"},
      {:cubrepo, github: "txssu/cubrepo"},
      # Telegram bot
      {:ex_gram, "~> 0.53.0"},
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
      # Cron
      {:quantum, "~> 3.0"},
      # UrFU API
      {:urfu_api, github: "txssu/urfu_api"},
      # Code quality
      {:credo, "~> 1.7.3", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.3", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1.2", only: [:dev, :test], runtime: false},
      {:styler, "~> 0.11.9", only: [:dev, :test], runtime: false},
      # Other
      {:typedstruct, "~> 0.5.2"},
      {:exconstructor, github: "txssu/exconstructor"},
      {:puid, "~> 2.1"}
    ]
  end

  defp aliases do
    [
      ci: [
        "compile --all-warnings --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "deps.audit",
        "dialyzer"
      ]
    ]
  end
end
