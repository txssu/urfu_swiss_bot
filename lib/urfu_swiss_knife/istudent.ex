defmodule UrFUSwissKnife.IStudent do
  @moduledoc false
  use Nebulex.Caching

  alias UrFUAPI.IStudent.Auth
  alias UrFUAPI.IStudent.Auth.Token
  alias UrFUAPI.IStudent.BRS
  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUSwissKnife.Cache

  @decorate cacheable(cache: Cache, key: {:istudent, username}, ttl: :timer.hours(24))
  @spec auth_user(map()) :: {:ok, Token.t()} | {:error, String.t()}
  def auth_user(%{username: username, password: password}) do
    Auth.sign_in(username, password)
  end

  @decorate cacheable(cache: Cache, key: {:get_filters, auth.username}, ttl: :timer.hours(24))
  @spec get_filters(Token.t()) :: {:ok, BRS.FiltersList.t()} | {:error, term()}
  def get_filters(auth) do
    BRS.get_filters(auth)
  end

  @decorate cacheable(cache: Cache, key: {:get_subjects, auth.username, group_id, year, semester}, ttl: :timer.hours(1))
  @spec get_subjects(Token.t(), String.t(), integer(), String.t()) :: {:ok, [Subject.t()]} | {:error, term()}
  def get_subjects(auth, group_id, year, semester) do
    BRS.get_subjects(auth, group_id, year, semester)
  end

  @decorate cache_put(cache: Cache, key: {:get_subjects, auth.username, group_id, year, semester}, ttl: :timer.hours(1))
  @spec update_subjects_cache(Token.t(), String.t(), integer(), String.t()) :: {:ok, [Subject.t()]} | {:error, term()}
  def update_subjects_cache(auth, group_id, year, semester) do
    BRS.get_subjects(auth, group_id, year, semester)
  end
end
