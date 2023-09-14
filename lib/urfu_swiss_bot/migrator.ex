defmodule UrFUSwissBot.Migrator do
  alias CubDB.Tx
  alias UrFUSwissBot.Repo

  def migrate do
    version = current_version()

    case to_migration(version + 1) do
      {:ok, migration} ->
        log("Migrate vsn#{version} -> vsn#{version + 1}")

        Repo.transaction(fn tx ->
          tx = apply(__MODULE__, migration, [tx])
          tx = increase_version(tx)
          {:commit, tx, :ok}
        end)

        migrate()

      :error ->
        :ok
    end
  end

  # Move users to separate table
  def to_version_1(tx) do
    Tx.select(tx)
    |> Enum.reduce(tx, fn {id, user}, tx_acc ->
      tx_acc
      |> Tx.delete(id)
      |> Tx.put({:users, id}, user)
    end)
  end

  # Add `is_admin` field
  def to_version_2(tx) do
    Tx.select(tx)
    |> Enum.reduce(tx, fn
      {{:users, _id} = key, user}, tx_acc ->
        updated_user = Map.put_new(user, :is_admin, false)
        Tx.put(tx_acc, key, updated_user)

      _, tx_acc ->
        tx_acc
    end)
  end

  def current_version do
    Repo.get(:version, 0)
  end

  def current_version(tx) do
    Tx.get(tx, :version, 0)
  end

  defp to_migration(version) do
    {:ok, String.to_existing_atom("to_version_#{version}")}
  rescue
    ArgumentError -> :error
  end

  defp increase_version(tx) do
    version = current_version(tx)

    Tx.put(tx, :version, version + 1)
  end

  def log(msg), do: IO.puts(msg)
end
