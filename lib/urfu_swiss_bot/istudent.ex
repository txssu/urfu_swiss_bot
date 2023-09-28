defmodule UrFUSwissBot.IStudent do
  alias UrFUSwissBot.Cache

  use Nebulex.Caching

  @decorate cacheable(cache: Cache, key: {username, password}, ttl: :timer.hours(24))
  def auth(username, password) do
    UrFUAPI.IStudent.Auth.API.sign_in(username, password)
  end

  @decorate cacheable(cache: Cache, key: auth, ttl: :timer.hours(1))
  def get_subjects(auth) do
    UrFUAPI.IStudent.BRS.API.get_subjects(auth)
  end

  @decorate cacheable(cache: Cache, key: {auth, subject}, ttl: :timer.hours(1))
  def preload_subject_scores(auth, subject) do
    UrFUAPI.IStudent.BRS.API.preload_subject_scores(auth, subject)
  end
end
