defmodule UrFUSwissKnife.CacheWarming do
  alias UrFUSwissKnife.Utils
  alias UrFUSwissKnife.IStudent
  alias UrFUSwissKnife.Modeus
  alias UrFUSwissKnife.UBU

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

      UBU.get_dates(auth)
    end

    :ok
  end

  def warm_istudent_brs do
    for user <- Accounts.get_users() do
      {:ok, auth} = IStudent.auth_user(user)

      IStudent.get_subjects(auth)
    end

    :ok
  end
end
