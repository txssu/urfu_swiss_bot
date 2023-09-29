defmodule UrFUSwissBot.Repo.FeedbackMessage do
  alias UrFUSwissBot.Repo

  defstruct id: 0,
            from_id: 0,
            original_id: 0

  @type t :: %__MODULE__{
          id: integer,
          from_id: integer,
          original_id: integer
        }

  @table :feedback_messages

  @spec save(t) :: :ok
  def save(%__MODULE__{id: id} = message), do: Repo.put({@table, id}, message)

  @spec load(integer) :: t | nil
  def load(id), do: Repo.get({@table, id})

  @spec delete(t) :: :ok
  def delete(%__MODULE__{id: id}), do: Repo.delete({@table, id})

  @spec new(integer, integer, integer) :: t
  def new(id, from_id, original_id),
    do: %__MODULE__{id: id, from_id: from_id, original_id: original_id}

  def select(options \\ []) do
    items = Repo.select(options)

    items
    |> Stream.filter(fn
      {{@table, _id}, _message} -> true
      _other -> false
    end)
    |> Stream.map(fn {{@table, _id}, message} -> message end)
  end
end
