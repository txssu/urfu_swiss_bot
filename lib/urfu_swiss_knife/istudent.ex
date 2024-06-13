defmodule UrFUSwissKnife.IStudent do
  @moduledoc false
  use Nebulex.Caching

  alias UrFUAPI.IStudent.Auth
  alias UrFUAPI.IStudent.Auth.Token
  alias UrFUAPI.IStudent.BRS
  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUSwissKnife.Cache

  @decorate cacheable(cache: Cache, key: {:istudent, username}, match: &match_auth/1)
  @spec auth_user(map()) :: {:ok, Token.t()} | {:error, String.t()}
  def auth_user(%{username: username, password: password}) do
    Auth.sign_in(username, password)
  end

  @spec match_auth({:ok, Token.t()} | {:error, String.t()}) ::
          false | {true, {:ok, Token.t()}, [{:ttl, integer}, ...]}
  def match_auth({:ok, %Token{expires_in: expires}} = result) do
    ttl = expires * 1000

    {true, result, [ttl: ttl]}
  end

  def match_auth({:error, _}) do
    false
  end

  @decorate cacheable(cache: Cache, key: {:get_filters, auth.username}, ttl: :timer.hours(24))
  @spec get_filters(Token.t()) :: {:ok, BRS.FiltersList.t()} | {:error, term()}
  def get_filters(auth) do
    BRS.get_filters(auth)
  end

  @decorate cacheable(cache: Cache, key: {:get_latest_filter, auth.username}, ttl: :timer.hours(24))
  @spec get_latest_filter(Token.t()) :: {:ok, {String.t(), integer(), String.t()}} | {:error, term()}
  def get_latest_filter(auth) do
    with {:ok, filters} <- BRS.get_filters(auth) do
      group =
        filters
        |> Map.fetch!(:groups)
        |> List.last()

      year_data = Enum.max_by(group.years, & &1.year)
      semester = Enum.max(year_data.semesters)

      {:ok, {group.group_id, year_data.year, semester}}
    end
  end

  @decorate cacheable(cache: Cache, key: {:get_subjects, auth.username, group_id, year, semester}, ttl: :timer.hours(1))
  @spec get_subjects(Token.t(), String.t(), integer(), String.t()) :: {:ok, [Subject.t()]} | {:error, term()}
  def get_subjects(auth, group_id, year, semester) do
    BRS.get_subjects(auth, group_id, year, semester)
  end

  @decorate cache_put(
              cache: Cache,
              key: {:update_subjects_cache, auth.username, group_id, year, semester},
              ttl: :timer.hours(1)
            )
  @spec update_subjects_cache(Token.t(), String.t(), integer(), String.t()) :: {:ok, [Subject.t()]} | {:error, term()}
  def update_subjects_cache(auth, group_id, year, semester) do
    BRS.get_subjects(auth, group_id, year, semester)
  end
end
