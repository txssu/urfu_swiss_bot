defmodule UrFUSwissBot.Application do
  @moduledoc false
  use Application

  @app :urfu_swiss_bot
  @supervisor_opts [strategy: :one_for_one, name: UrFUSwissBot.Supervisor]

  @impl Application
  @spec start(Application.start_type(), start_args :: term) ::
          {:ok, pid} | {:ok, pid, Application.state()} | {:error, reason :: term}
  def start(_type, _args) do
    telegram_token = Application.get_env(@app, UrFUSwissBot.Bot)[:token]
    data_dir = Application.get_env(@app, UrFUSwissBot.Repo)[:database_folder]

    children = [
      {CubDB, [name: UrFUSwissKnife.Repo, data_dir: data_dir]},
      UrFUSwissBot.Cache,
      ExGram,
      {UrFUSwissBot.Bot, [method: :polling, token: telegram_token]}
    ]

    migrate(data_dir)
    Supervisor.start_link(children, @supervisor_opts)
  end

  @spec migrate(String.t()) :: :ok
  defp migrate(data_dir) do
    {:ok, db} = CubDB.start_link(data_dir: data_dir)

    :ok = UrFUSwissBot.Migrator.migrate(db)

    :ok = GenServer.stop(db)
  end
end
