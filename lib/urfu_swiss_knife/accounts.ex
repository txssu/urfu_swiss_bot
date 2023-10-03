defmodule UrFUSwissKnife.Accounts do
  alias UrFUSwissKnife.Repo

  alias UrFUSwissKnife.Accounts.User

  @spec create_user(integer()) :: User.t()
  def create_user(id) do
    User.new(id: id)
  end

  @spec get_user(integer()) :: User.t()
  def get_user(id) do
    Repo.get(User, id)
  end

  @spec save_user(User.t()) :: User.t()
  def save_user(user) do
    :ok = Repo.save(user)

    user
  end

  @spec delete_user(User.t()) :: :ok
  def delete_user(user) do
    Repo.delete(user)
  end

  @spec get_users :: Enumerable.t(User.t())
  def get_users do
    Repo.select(User)
  end

  @spec get_admins :: Enumerable.t(User.t())
  def get_admins do
    User
    |> Repo.select()
    |> Stream.filter(& &1.is_admin)
  end
end
