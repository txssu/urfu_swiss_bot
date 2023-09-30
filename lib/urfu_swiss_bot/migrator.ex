defmodule UrFUSwissBot.Migrator do
  alias CubDB.Tx
  alias UrFUSwissBot.Repo

  @spec migrate() :: :ok
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
  @spec to_version_1(Tx.t()) :: Tx.t()
  def to_version_1(tx) do
    items = Tx.select(tx)

    Enum.reduce(items, tx, fn {id, user}, tx_acc ->
      tx_acc
      |> Tx.delete(id)
      |> Tx.put({:users, id}, user)
    end)
  end

  # Add `is_admin` field
  @spec to_version_2(Tx.t()) :: Tx.t()
  def to_version_2(tx) do
    items = Tx.select(tx)

    Enum.reduce(items, tx, fn
      {{:users, _id} = key, user}, tx_acc ->
        updated_user = Map.put_new(user, :is_admin, false)
        Tx.put(tx_acc, key, updated_user)

      _others, tx_acc ->
        tx_acc
    end)
  end

  @spec current_version() :: integer()
  def current_version do
    Repo.get(:version, 0)
  end

  @spec current_version(Tx.t()) :: integer()
  def current_version(tx) do
    Tx.get(tx, :version, 0)
  end

  @spec to_migration(integer()) :: {:ok, atom()} | :error
  defp to_migration(version) do
    {:ok, String.to_existing_atom("to_version_#{version}")}
  rescue
    ArgumentError -> :error
  end

  @spec increase_version(Tx.t()) :: Tx.t()
  defp increase_version(tx) do
    version = current_version(tx)

    Tx.put(tx, :version, version + 1)
  end

  @spec log(String.t()) :: :ok
  def log(msg) do
    # credo:disable-for-next-line
    IO.puts(msg)
  end
end
