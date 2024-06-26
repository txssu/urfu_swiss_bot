defmodule UrFUSwissKnife.CacheWarming do
  @moduledoc false
  alias UrFUSwissBot.Notifications.BRSUpdateFormatter
  alias UrFUSwissBot.UpdatesNotifier
  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.Accounts.User
  alias UrFUSwissKnife.IStudent
  alias UrFUSwissKnife.Modeus
  alias UrFUSwissKnife.PersistentCache
  alias UrFUSwissKnife.UBU
  alias UrFUSwissKnife.Updates.BRSDeltaFinder
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
        "Asia/Yekaterinburg"
        |> DateTime.now!()
        |> Utils.start_of_day()

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
    for {user, auth} <- get_authed_users(IStudent) do
      {:ok, {group_id, year, semester}} = IStudent.get_latest_filter(auth)

      {:ok, subjects} = IStudent.update_subjects_cache(auth, group_id, year, semester)

      was = PersistentCache.get_brs(user.id)
      became = PersistentCache.create_brs(user.id, subjects)

      added = BRSDeltaFinder.find_added(was.subjects, became.subjects)
      changed = BRSDeltaFinder.find_changed(was.subjects, became.subjects)
      deleted = BRSDeltaFinder.find_deleted(was.subjects, became.subjects)

      unless Enum.all?([added, changed, deleted], &Enum.empty?/1) do
        notification = BRSUpdateFormatter.format_update(added, changed, deleted)
        UrfuSwissBot.Notifications.send_notification(user.id, notification)
      end
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
