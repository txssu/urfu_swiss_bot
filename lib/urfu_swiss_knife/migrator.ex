# credo:disable-for-this-file Credo.Check.Refactor.ABCSize
defmodule UrFUSwissBot.Migrator do
  @moduledoc false
  alias CubDB.Tx

  require Logger

  @spec migrate(GenServer.server()) :: :ok
  def migrate(db) do
    version = CubDB.get(db, :version, 0)

    case to_migration(version + 1) do
      {:ok, migration} ->
        Logger.info("Migrate vsn#{version} -> vsn#{version + 1}")

        CubDB.transaction(db, fn tx ->
          tx = apply(__MODULE__, migration, [tx])
          tx = increase_version(tx)
          {:commit, tx, :ok}
        end)

        migrate(db)

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

  # Convert structs to maps
  @spec to_version_3(Tx.t()) :: Tx.t()
  def to_version_3(tx) do
    items = Tx.select(tx)

    Enum.reduce(items, tx, fn
      {{_key, _table} = key, struct}, tx_acc ->
        Tx.put(tx_acc, key, Map.from_struct(struct))

      _others, tx_acc ->
        tx_acc
    end)
  end

  # Fix typo in table's name
  @spec to_version_4(Tx.t()) :: Tx.t()
  def to_version_4(tx) do
    items = Tx.select(tx)

    Enum.reduce(items, tx, fn
      {{:feedback_message, id} = key, item}, tx_acc ->
        tx_acc
        |> Tx.delete(key)
        |> Tx.put({:feedback_messages, id}, item)

      _others, tx_acc ->
        tx_acc
    end)
  end

  # Change ids meaning
  @spec to_version_5(Tx.t()) :: Tx.t()
  def to_version_5(tx) do
    items = Tx.select(tx)

    Enum.reduce(items, tx, fn
      {{:feedback_messages, _id} = key, item}, tx_acc ->
        updated_item =
          item
          |> Map.put(:id, item.original_id)
          |> Map.delete(:original_id)
          |> Map.put(:forwared_ids, [item.id])

        Tx.put(tx_acc, key, updated_item)

      _others, tx_acc ->
        tx_acc
    end)
  end

  # Rename schedule-date-*some-date* to schedule-date-by-arrows
  @spec to_version_6(Tx.t()) :: Tx.t()
  def to_version_6(tx) do
    items = Tx.select(tx)

    Enum.reduce(items, tx, fn
      {{:metric_events, _id} = key, %{command: "schedule-date-" <> _date} = item}, tx_acc ->
        updated_item =
          Map.put(item, :command, "schedule-date-by-arrows")

        Tx.put(tx_acc, key, updated_item)

      _others, tx_acc ->
        tx_acc
    end)
  end

  # Rename metric_events to metric_command_calls
  @spec to_version_7(Tx.t()) :: Tx.t()
  def to_version_7(tx) do
    items = Tx.select(tx)

    Enum.reduce(items, tx, fn
      {{:metric_events, id}, item}, tx_acc ->
        Tx.put(tx_acc, {:metric_command_calls, id}, item)

      _others, tx_acc ->
        tx_acc
    end)
  end

  # Rename metric events commands
  @spec to_version_8(Tx.t()) :: Tx.t()
  def to_version_8(tx) do
    items = Tx.select(tx)

    Enum.reduce(items, tx, fn
      {{:metric_command_calls, _id} = key, %{command: "start"} = item}, tx_acc ->
        item = Map.put(item, :command, "/start")
        Tx.put(tx_acc, key, item)

      {{:metric_command_calls, _id} = key, %{command: "/start"}}, tx_acc ->
        Tx.delete(tx_acc, key)

      {{:metric_command_calls, _id} = key, %{command: "menu"} = item}, tx_acc ->
        item = Map.put(item, :command, "/menu")
        Tx.put(tx_acc, key, item)

      {{:metric_command_calls, _id} = key, %{command: "/menu"}}, tx_acc ->
        Tx.delete(tx_acc, key)

      {{:metric_command_calls, _id} = key, %{command: data} = item}, tx_acc ->
        [command | _args] = String.split(data, ":")
        item = Map.put(item, :command, command)
        Tx.put(tx_acc, key, item)

      _others, tx_acc ->
        tx_acc
    end)
  end

  @spec to_migration(integer()) :: {:ok, atom()} | :error
  defp to_migration(version) do
    {:ok, String.to_existing_atom("to_version_#{version}")}
  rescue
    ArgumentError -> :error
  end

  @spec increase_version(Tx.t()) :: Tx.t()
  defp increase_version(tx) do
    version = Tx.get(tx, :version, 0)
    Tx.put(tx, :version, version + 1)
  end
end
