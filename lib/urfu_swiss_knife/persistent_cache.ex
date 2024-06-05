defmodule UrFUSwissKnife.PersistentCache do
  @moduledoc false
  alias UrFUSwissKnife.PersistentCache.CommunalCharges
  alias UrFUSwissKnife.Repo

  @spec create_communal_charges(integer(), map()) :: :ok
  def create_communal_charges(user_id, fields) do
    fields_with_user = Map.put(fields, :id, user_id)

    fields_with_user
    |> CommunalCharges.new()
    |> Repo.save()
  end

  @spec get_communal_charges(integer()) :: CommunalCharges.t() | nil
  def get_communal_charges(user_id) do
    Repo.get(CommunalCharges, user_id)
  end
end
