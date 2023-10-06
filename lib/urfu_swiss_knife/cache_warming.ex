defmodule UrFUSwissKnife.CacheWarming do
  alias UrFUSwissKnife.Cache
  alias UrFUSwissKnife.Utils
  alias UrFUSwissKnife.IStudent
  alias UrFUSwissKnife.Modeus
  alias UrFUSwissKnife.UBU

  alias UrFUSwissBot.UpdatesNotifier

  alias UrFUSwissKnife.Accounts

  def warm_today_schedule do
    for user <- Accounts.get_users() do
      {:ok, auth} = Modeus.auth_user(user)

      today =
        DateTime.utc_now()
        |> Utils.start_of_day()
        |> Utils.to_yekaterinburg_zone()

      Modeus.get_schedule_by_day(auth, today)
    end

    :ok
  end

  def warm_ubu_dates do
    for user <- Accounts.get_users() do
      {:ok, auth} = UBU.auth_user(user)

      was = Cache.get({:get_dates, user.username})
      became = UBU.update_dates_cache(auth)

      unless is_nil(was) do
        UpdatesNotifier.update_ubu_debt(user, was, became)
      end
    end

    :ok
  end

  def warm_istudent_brs do
    for user <- Accounts.get_users() do
      {:ok, auth} = IStudent.auth_user(user)

      IStudent.update_subjects_cache(auth)
    end

    :ok
  end
end
