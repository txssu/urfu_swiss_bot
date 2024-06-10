defmodule UrFUSwissKnife.Accounts do
  @moduledoc false
  alias UrFUSwissKnife.Accounts.User
  alias UrFUSwissKnife.Repo

  @spec create_user(integer()) :: User.t()
  def create_user(id) do
    User.new(id: id)
  end

  @spec edit_user_credentials(User.t(), String.t(), String.t()) :: User.t()
  def edit_user_credentials(user, username, password) do
    User.set_credentials(user, username, password)
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

  @spec set_auth_state(User.t()) :: User.t()
  def set_auth_state(user) do
    user
    |> User.set_state(:auth)
    |> save_user()
  end

  @spec set_sending_feedback_state(User.t()) :: User.t()
  def set_sending_feedback_state(user) do
    user
    |> User.set_state(:sending_feeback)
    |> save_user()
  end

  @spec set_sending_schedule_date_state(User.t()) :: User.t()
  def set_sending_schedule_date_state(user) do
    user
    |> User.set_state(:sending_schedule_date)
    |> save_user()
  end

  @spec remove_state(User.t()) :: User.t()
  def remove_state(user) do
    user
    |> User.nil_state()
    |> save_user()
  end

  @spec delete_user(User.t()) :: User.t()
  def delete_user(user) do
    user
    |> User.delete()
    |> save_user()
  end

  @spec recover_user(User.t()) :: User.t()
  def recover_user(user) do
    user
    |> User.recover()
    |> set_auth_state()
    |> save_user()
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

  @spec set_user_default_brs_args(User.t(), list()) :: User.t()
  def set_user_default_brs_args(user, args) do
    save_user(%User{user | default_brs_args: args})
  end
end
