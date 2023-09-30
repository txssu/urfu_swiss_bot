defmodule UrFUSwissBot.UBU do
  alias UrFUAPI.UBU.Auth
  alias UrFUAPI.UBU.Auth.Token
  alias UrFUAPI.UBU.CommunalCharges
  alias UrFUAPI.UBU.CommunalCharges.Info

  alias UrFUSwissBot.Cache

  use Nebulex.Caching

  @decorate cacheable(cache: Cache, key: {:ubu_auth, username, password}, ttl: :timer.hours(24))
  @spec auth(String.t(), String.t()) :: {:ok, Token.t()} | {:error, any()}
  def auth(username, password) do
    Auth.sign_in(username, password)
  end

  @decorate cacheable(cache: Cache, key: {:get_dates, auth}, ttl: :timer.hours(24))
  @spec get_dates(Token.t()) :: Info.t()
  def get_dates(auth) do
    CommunalCharges.get_dates(auth)
  end
end
