defmodule UrFUSwissKnife.UBU do
  alias UrFUAPI.UBU.Auth
  alias UrFUAPI.UBU.Auth.Token
  alias UrFUAPI.UBU.CommunalCharges
  alias UrFUAPI.UBU.CommunalCharges.Info

  alias UrFUSwissKnife.Cache

  use Nebulex.Caching

  @decorate cacheable(cache: Cache, key: {:ubu_auth, username}, ttl: :timer.hours(24))
  @spec auth_user(map()) :: {:ok, Token.t()} | {:error, String.t()}
  def auth_user(%{username: username, password: password}) do
    Auth.sign_in(username, password)
  end

  @decorate cacheable(cache: Cache, key: {:get_dates, auth.username}, ttl: :timer.hours(24))
  @spec get_dates(Token.t()) :: Info.t()
  def get_dates(auth) do
    CommunalCharges.get_dates(auth)
  end
end
