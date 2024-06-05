defmodule UrFUSwissKnife.CacheWarming do
  @moduledoc false
  alias UrFUSwissBot.UpdatesNotifier
  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.Accounts.User
  alias UrFUSwissKnife.IStudent
  alias UrFUSwissKnife.Modeus
  alias UrFUSwissKnife.PersistentCache
  alias UrFUSwissKnife.UBU
  alias UrFUSwissKnife.Utils

  @spec warm_all() :: :ok
  def warm_all do
    warm_today_schedule()
    warm_ubu_dates()
    warm_istudent_brs()
  end

  @spec warm_today_schedule :: :ok
  def warm_today_schedule do
    for {_user, auth} <- get_authed_users(Modeus) do
      today =
        Utils.yekaterinburg_start_of_day(DateTime.utc_now())

      Modeus.get_schedule_by_day(auth, today)
    end

    :ok
  end

  @spec warm_ubu_dates :: :ok
  def warm_ubu_dates do
    for {user, auth} <- get_authed_users(UBU) do
      was = PersistentCache.get_communal_charges(user.id)
      became = UBU.update_dates_cache(auth)
      PersistentCache.create_communal_charges(user.id, became)

      unless is_nil(was) do
        UpdatesNotifier.update_ubu_debt(user, was, became)
      end
    end

    :ok
  end

  @spec warm_istudent_brs :: :ok
  def warm_istudent_brs do
    for {_user, auth} <- get_authed_users(IStudent) do
      IStudent.update_subjects_cache(auth)
    end

    :ok
  end

  @spec get_authed_users(module()) :: Enumerable.t(User.t())
  defp get_authed_users(auth_module) do
    Accounts.get_users()
    |> Stream.map(fn user -> {user, auth_module.auth_user(user)} end)
    |> Stream.filter(&match?({:ok, _auth}, elem(&1, 1)))
    |> Stream.map(fn {user, {:ok, auth}} -> {user, auth} end)
  end
end
