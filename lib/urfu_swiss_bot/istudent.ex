defmodule UrFUSwissBot.IStudent do
  alias UrFUSwissBot.Cache

  use Nebulex.Caching

  @decorate cacheable(cache: Cache, key: {:istudent, username, password}, ttl: :timer.hours(24))
  def auth(username, password) do
    UrFUAPI.IStudent.Auth.sign_in(username, password)
  end

  @decorate cacheable(cache: Cache, key: {:get_subjects, auth}, ttl: :timer.hours(1))
  def get_subjects(auth) do
    UrFUAPI.IStudent.BRS.get_subjects(auth)
  end

  @decorate cacheable(
              cache: Cache,
              key: {:perload_subject_scores, auth, subject},
              ttl: :timer.hours(1)
            )
  def preload_subject_scores(auth, subject) do
    UrFUAPI.IStudent.BRS.preload_subject_scores(auth, subject)
  end
end
