defmodule UrfuSwissKnife.Application do
  @moduledoc false
  use Application

  @app :urfu_swiss_knife
  @supervisor_opts [strategy: :one_for_one, name: UrfuSwissBot.Supervisor]

  @impl Application
  @spec start(Application.start_type(), start_args :: term) ::
          {:ok, pid} | {:ok, pid, Application.state()} | {:error, reason :: term}
  def start(_type, _args) do
    telegram_token = Application.get_env(@app, UrfuSwissBot.Bot)[:token]
    data_dir = Application.get_env(@app, UrfuSwissBot.Repo)[:database_folder]

    children = [
      {CubDB, [name: UrfuSwissKnife.Repo, data_dir: data_dir]},
      UrfuSwissKnife.Cache,
      ExGram,
      {UrfuSwissBot.Bot, [method: :polling, token: telegram_token]},
      UrfuSwissKnife.Scheduler
    ]

    migrate(data_dir)
    Supervisor.start_link(children, @supervisor_opts)
  end

  @spec migrate(String.t()) :: :ok
  defp migrate(data_dir) do
    {:ok, db} = CubDB.start_link(data_dir: data_dir)

    :ok = UrfuSwissBot.Migrator.migrate(db)

    :ok = GenServer.stop(db)
  end
end
