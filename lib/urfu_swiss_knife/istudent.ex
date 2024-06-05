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

  @decorate cacheable(cache: Cache, key: {:get_subjects, auth.username}, ttl: :timer.hours(1))
  @spec get_subjects(Token.t()) :: [Subject.t()]
  def get_subjects(auth) do
    do_get_subjects(auth)
  end

  @decorate cache_put(cache: Cache, key: {:get_subjects, auth.username}, ttl: :timer.hours(1))
  @spec update_subjects_cache(Token.t()) :: [Subject.t()]
  def update_subjects_cache(auth) do
    do_get_subjects(auth)
  end

  defp do_get_subjects(auth) do
    {:ok, filters} = BRS.get_filters(auth)

    group = List.last(filters.groups)
    group_id = group.group_id
    year_info = List.last(group.years)
    year = year_info.year
    semester = List.last(year_info.semesters)

    {:ok, subjects} = BRS.get_subjects(auth, group_id, year, semester)

    subjects_ids = Enum.map(subjects, &Map.fetch!(&1, :id))

    subjects_ids
    |> Enum.reject(&all_digits/1)
    |> Enum.map(fn subject_id ->
      auth
      |> BRS.get_subject(group_id, year, semester, subject_id)
      |> elem(1)
    end)
  end

  defp all_digits(str) do
    str
    |> String.codepoints()
    |> Enum.all?(&(&1 in ~w(0 1 2 3 4 5 6 7 8 9)))
  end
end
