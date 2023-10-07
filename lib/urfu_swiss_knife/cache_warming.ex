defmodule UrFUSwissKnife.CacheWarming do
  alias UrFUSwissKnife.Cache
  alias UrFUSwissKnife.IStudent
  alias UrFUSwissKnife.Modeus
  alias UrFUSwissKnife.UBU
  alias UrFUSwissKnife.Utils

  alias UrFUSwissBot.UpdatesNotifier

  alias UrFUSwissKnife.Accounts

  @spec warm_today_schedule :: :ok
  def warm_today_schedule do
    for {_user, auth} <- get_authed_users(Modeus) do
      today =
        DateTime.utc_now()
        |> Utils.start_of_day()
        |> Utils.to_yekaterinburg_zone()

      Modeus.get_schedule_by_day(auth, today)
    end

    :ok
  end

  @spec warm_ubu_dates :: :ok
  def warm_ubu_dates do
    for {user, auth} <- get_authed_users(UBU) do
      was = Cache.get({:get_dates, user.username})
      became = UBU.update_dates_cache(auth)

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

  defp get_authed_users(auth_module) do
    Accounts.get_users()
    |> Stream.map(fn user -> {user, auth_module.auth_user(user)} end)
    |> Stream.filter(&match?({:ok, _auth}, elem(&1, 1)))
    |> Stream.map(fn {user, {:ok, auth}} -> {user, auth} end)
  end
end
