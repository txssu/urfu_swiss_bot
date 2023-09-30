defmodule UrFUSwissBot.Repo do
  @repo __MODULE__

  @spec put(CubDB.key(), CubDB.value()) :: :ok
  def put(key, value), do: CubDB.put(@repo, key, value)

  @spec get(CubDB.key(), CubDB.value()) :: CubDB.value()
  def get(key, default \\ nil), do: CubDB.get(@repo, key, default)

  @spec select([CubDB.select_option()]) :: Enumerable.t()
  def select(options \\ []), do: CubDB.select(@repo, options)

  @spec delete(CubDB.key()) :: :ok
  def delete(key), do: CubDB.delete(@repo, key)

  @spec transaction((CubDB.Tx.t() -> {:cancel, result} | {:commit, CubDB.Tx.t(), result})) ::
          result
        when result: any()
  def transaction(fun), do: CubDB.transaction(@repo, fun)
end
