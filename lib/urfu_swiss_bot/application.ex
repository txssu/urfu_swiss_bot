defmodule UrFUSwissBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    data_dir = Application.get_env(:urfu_swiss_bot, UrFUSwissBot.Repo)[:database_folder]
    telegram_token = Application.get_env(:urfu_swiss_bot, UrFUSwissBot.Bot)[:token]

    children = [
      {CubDB, [data_dir: data_dir, name: UrFUSwissBot.Repo]},
      UrFUSwissBot.Cache,
      ExGram,
      {UrFUSwissBot.Bot, [method: :polling, token: telegram_token]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UrFUSwissBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
