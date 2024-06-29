defmodule UrFUSwissKnife.BRSShortLink do
  @moduledoc false
  use TypedStruct
  use Puid, chars: :safe32, total: 25_000, risk: 1.0e6

  alias UrFUSwissKnife.Repo

  @type id :: String.t()
  @type args :: tuple()

  typedstruct do
    field :id, String.t()
    field :user_id, integer()
    field :args, {term(), term(), term(), term()}
  end

  @spec get_args(id()) :: args()
  def get_args(id) do
    case Repo.get(__MODULE__, id) do
      nil -> nil
      link -> link.args
    end
  end

  @spec get_link(integer(), any(), any(), any(), any()) :: id()
  def get_link(user_id, group_id, year, semester, subject_id) do
    args = {group_id, year, semester, subject_id}

    __MODULE__
    |> Repo.select()
    |> Enum.find(&(&1.args == args))
    |> case do
      nil -> create_link(user_id, args)
      link -> link.id
    end
  end

  @spec create_link(integer(), args()) :: binary()
  def create_link(user_id, args) do
    link = %__MODULE__{id: generate(), user_id: user_id, args: args}
    Repo.save(link)
    link.id
  end
end
