defmodule UrFUSwissBot.Repo do
  @repo __MODULE__

  def put(key, value), do: CubDB.put(@repo, key, value)
  @spec get(any, any) :: any
  def get(key, default \\ nil), do: CubDB.get(@repo, key, default)
  def delete(key), do: CubDB.delete(@repo, key)
end
