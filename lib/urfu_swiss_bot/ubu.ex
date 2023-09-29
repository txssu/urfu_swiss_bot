defmodule UrFUSwissBot.UBU do
  alias UrFUSwissBot.Cache

  use Nebulex.Caching

  @decorate cacheable(cache: Cache, key: {:ubu_auth, username, password}, ttl: :timer.hours(24))
  def auth(username, password) do
    UrFUAPI.UBU.Auth.sign_in(username, password)
  end

  @decorate cacheable(cache: Cache, key: {:get_dates, auth}, ttl: :timer.hours(24))
  def get_dates(auth) do
    UrFUAPI.UBU.CommunalCharges.get_dates(auth)
  end
end
