defmodule UrFUSwissKnife.Metrics do
  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.Repo

  alias UrFUSwissKnife.Metrics.CommandCall

  @spec hit_command(ExConstructor.map_or_kwlist()) :: :ok
  def hit_command(fields) do
    event = CommandCall.new(fields)

    Repo.save(event)
  end

  @spec commands_usage() :: %{integer() => String.t()}
  def commands_usage do
    admins =
      Enum.map(Accounts.get_admins(), fn %{id: id} -> id end)

    CommandCall
    |> Repo.select()
    |> Stream.reject(fn %{by_user_id: by_user_id} -> by_user_id in admins end)
    |> Enum.group_by(fn %{command: command} -> command end)
    |> Enum.map(fn {command, calls} -> {command, Enum.count(calls)} end)
    |> Enum.into(%{})
  end
end
