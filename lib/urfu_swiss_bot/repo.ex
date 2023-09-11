defmodule UrFUSwissBot.Repo do
  @repo __MODULE__

  @spec put(CubDB.key(), CubDB.value()) :: :ok
  def put(key, value), do: CubDB.put(@repo, key, value)

  @spec get(CubDB.key(), CubDB.value()) :: CubDB.value()
  def get(key, default \\ nil), do: CubDB.get(@repo, key, default)

  @spec delete(CubDB.key()) :: :ok
  def delete(key), do: CubDB.delete(@repo, key)
end
