defmodule UrFUSwissBot.Application do
  @moduledoc false
  use Application

  @app :urfu_swiss_bot
  @supervisor_opts [strategy: :one_for_one, name: UrFUSwissBot.Supervisor]

  @impl true
  def start(_type, _args) do
    migrate()

    telegram_token = Application.get_env(@app, UrFUSwissBot.Bot)[:token]

    children = [
      database_spec(),
      UrFUSwissBot.Cache,
      UrFUSwissBot.Scheduler,
      ExGram,
      {UrFUSwissBot.Bot, [method: :polling, token: telegram_token]}
    ]

    Supervisor.start_link(children, @supervisor_opts)
  end

  defp migrate do
    {:ok, pid} = Supervisor.start_link([database_spec()], @supervisor_opts)

    UrFUSwissBot.Migrator.migrate()

    :ok = Supervisor.stop(pid)
  end

  defp database_spec do
    data_dir = Application.get_env(@app, UrFUSwissBot.Repo)[:database_folder]
    {CubDB, [data_dir: data_dir, name: UrFUSwissBot.Repo]}
  end
end
