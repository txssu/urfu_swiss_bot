defmodule UrFUSwissBot.IStudent do
  alias UrFUAPI.IStudent.Auth
  alias UrFUAPI.IStudent.Auth.Token
  alias UrFUAPI.IStudent.BRS
  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUSwissBot.Cache

  use Nebulex.Caching

  @decorate cacheable(cache: Cache, key: {:istudent, username}, ttl: :timer.hours(24))
  @spec auth_user(map()) :: {:ok, Token.t()} | {:error, String.t()}
  def auth_user(%{username: username, password: password}) do
    Auth.sign_in(username, password)
  end

  @decorate cacheable(cache: Cache, key: {:get_subjects, auth}, ttl: :timer.hours(1))
  @spec get_subjects(Token.t()) :: [Subject.t()]
  def get_subjects(auth) do
    BRS.get_subjects(auth)
  end

  @decorate cacheable(
              cache: Cache,
              key: {:perload_subject_scores, auth, subject},
              ttl: :timer.hours(1)
            )
  @spec preload_subject_scores(Token.t(), Subject.t()) :: Subject.t()
  def preload_subject_scores(auth, subject) do
    BRS.preload_subject_scores(auth, subject)
  end
end
