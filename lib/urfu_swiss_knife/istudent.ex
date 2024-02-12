defmodule UrFUSwissKnife.Istudent do
  @moduledoc false
  use Nebulex.Caching

  alias UrfuApi.Istudent.Auth
  alias UrfuApi.Istudent.Auth.Token
  alias UrfuApi.Istudent.Brs
  alias UrfuApi.Istudent.Brs.Subject
  alias UrFUSwissKnife.Cache

  @decorate cacheable(cache: Cache, key: {:istudent, username}, ttl: :timer.hours(24))
  @spec auth_user(map()) :: {:ok, Token.t()} | {:error, String.t()}
  def auth_user(%{username: username, password: password}) do
    Auth.sign_in(username, password)
  end

  @decorate cacheable(cache: Cache, key: {:get_subjects, auth.username}, ttl: :timer.hours(1))
  @spec get_subjects(Token.t()) :: [Subject.t()]
  def get_subjects(auth) do
    auth
    |> Brs.get_subjects()
    |> Enum.map(&Brs.preload_subject_scores(auth, &1))
  end

  @decorate cache_put(cache: Cache, key: {:get_subjects, auth.username}, ttl: :timer.hours(1))
  @spec update_subjects_cache(Token.t()) :: [Subject.t()]
  def update_subjects_cache(auth) do
    auth
    |> Brs.get_subjects()
    |> Enum.map(&Brs.preload_subject_scores(auth, &1))
  end
end
