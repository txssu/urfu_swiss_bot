defmodule UrFUSwissKnife.Application do
  @moduledoc false
  use Application

  @app :urfu_swiss_knife
  @supervisor_opts [strategy: :one_for_one, name: UrFUSwissBot.Supervisor]

  @impl Application
  @spec start(Application.start_type(), start_args :: term) ::
          {:ok, pid} | {:ok, pid, Application.state()} | {:error, reason :: term}
  def start(_type, _args) do
    data_dir = Application.get_env(@app, UrFUSwissBot.Repo)[:database_folder]

    children =
      [
        {CubDB, [name: UrFUSwissKnife.Repo, data_dir: data_dir]},
        UrFUSwissKnife.Cache
      ]
      |> maybe_add_telegram_bot()
      |> maybe_add_scheduler()

    migrate(data_dir)
    Supervisor.start_link(children, @supervisor_opts)
  end

  @spec migrate(String.t()) :: :ok
  defp migrate(data_dir) do
    {:ok, db} = CubDB.start_link(data_dir: data_dir)

    :ok = UrFUSwissBot.Migrator.migrate(db)

    :ok = GenServer.stop(db)
  end

  defp maybe_add_telegram_bot(children) do
    token = Application.get_env(@app, UrFUSwissBot.Bot)[:token]
    telegram_children = [ExGram, {UrFUSwissBot.Bot, [method: :polling, token: token]}]

    if Application.get_env(@app, UrFUSwissBot.Bot)[:enabled] do
      Enum.concat(children, telegram_children)
    else
      children
    end
  end

  defp maybe_add_scheduler(children) do
    if Application.get_env(@app, UrFUSwissKnife.Scheduler)[:enabled] do
      [UrFUSwissKnife.Scheduler | children]
    else
      children
    end
  end
end
