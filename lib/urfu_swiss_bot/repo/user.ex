defmodule UrFUSwissBot.Repo.User do
  alias UrFUSwissBot.Repo

  defstruct id: 0,
            username: nil,
            password: nil,
            state: nil,
            is_admin: false

  @table :users

  @type state :: {module, atom}

  @type t :: %__MODULE__{
          id: integer,
          username: String.t() | nil,
          password: String.t() | nil,
          state: state | nil,
          is_admin: boolean
        }

  @spec save(t) :: :ok
  def save(%__MODULE__{id: id} = user), do: Repo.put({@table, id}, user)

  @spec load(integer) :: t | nil
  def load(id), do: Repo.get({@table, id})

  @spec delete(t) :: :ok
  def delete(%__MODULE__{id: id}), do: Repo.delete({@table, id})

  @spec new(integer) :: t
  def new(id), do: %__MODULE__{id: id}

  @spec set_credentials(t, String.t(), String.t()) :: t
  def set_credentials(%__MODULE__{} = user, username, password),
    do: %{user | username: username, password: password}

  @spec delete_credentials(t) :: t
  def delete_credentials(%__MODULE__{} = user),
    do: %{user | username: nil, password: nil}

  @spec set_state(t, state) :: t
  def set_state(user, state), do: %{user | state: state}

  @spec nil_state(t) :: t
  def nil_state(user), do: %{user | state: nil}

  def select(options \\ []) do
    items = Repo.select(options)

    items
    |> Stream.filter(fn
      {{@table, _id}, _user} -> true
      _other -> false
    end)
    |> Stream.map(fn {{@table, _id}, user} -> user end)
  end

  def select_admins(options \\ []) do
    items = select(options)

    Stream.filter(items, fn user -> user.is_admin end)
  end
end
