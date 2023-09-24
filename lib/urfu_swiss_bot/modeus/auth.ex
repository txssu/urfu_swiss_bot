defmodule UrFUSwissBot.Modeus.Auth do
  alias UrFUSwissBot.Cache
  alias UrFUSwissBot.Modeus.AuthAPI
  alias UrFUSwissBot.Repo.User

  use Nebulex.Caching

  def register_user(user, username, password) do
    authed_user = User.set_credentials(user, username, password)

    case auth_user(authed_user) do
      {:ok, _auth} ->
        {:ok, authed_user}

      err ->
        err
    end
  end

  @decorate cacheable(cache: Cache, key: user, match: &match_auth/1)
  def auth_user(user) do
    AuthAPI.auth(user.username, user.password)
  end

  def match_auth({:ok, auth} = result) do
    ttl = :timer.seconds(auth.expires - System.os_time(:second))

    {true, result, [ttl: ttl]}
  end

  def match_auth({:error, _}) do
    false
  end
end
