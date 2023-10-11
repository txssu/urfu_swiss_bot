defmodule UrFUSwissKnife.PersistentCache do
  alias UrFUSwissKnife.Repo

  alias UrFUSwissKnife.PersistentCache.CommunalCharges

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
