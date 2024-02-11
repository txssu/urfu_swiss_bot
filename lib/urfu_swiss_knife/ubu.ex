defmodule UrFUSwissKnife.Ubu do
  @moduledoc false
  use Nebulex.Caching

  alias UrfuApi.Ubu.Auth
  alias UrfuApi.Ubu.Auth.Token
  alias UrfuApi.Ubu.CommunalCharges
  alias UrfuApi.Ubu.CommunalCharges.Info
  alias UrFUSwissKnife.Cache

  @decorate cacheable(cache: Cache, key: {:ubu_auth, username}, ttl: :timer.hours(24))
  @spec auth_user(map()) :: {:ok, Token.t()} | {:error, String.t()}
  def auth_user(%{username: username, password: password}) do
    Auth.sign_in(username, password)
  end

  @decorate cacheable(cache: Cache, key: {:get_dates, auth.username}, ttl: :timer.hours(36))
  @spec get_dates(Token.t()) :: Info.t()
  def get_dates(auth) do
    CommunalCharges.get_dates(auth)
  end

  @decorate cache_put(cache: Cache, key: {:get_dates, auth.username}, ttl: :timer.hours(36))
  @spec update_dates_cache(Token.t()) :: Info.t()
  def update_dates_cache(auth) do
    CommunalCharges.get_dates(auth)
  end
end
