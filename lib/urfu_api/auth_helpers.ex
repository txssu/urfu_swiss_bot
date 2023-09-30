defmodule UrFUAPI.AuthHelpers do
  @spec ensure_redirect(Tesla.Env.t()) :: {:ok, Tesla.Env.t()} | :error
  def ensure_redirect(response)

  def ensure_redirect(%Tesla.Env{status: status} = response)
      when status >= 300 and status < 400 do
    {:ok, response}
  end

  def ensure_redirect(_not_redirect), do: :error

  @spec fetch_location!(Tesla.Env.t()) :: String.t()
  def fetch_location!(%Tesla.Env{} = env) do
    fetch_header!(env, "location")
  end

  @spec fetch_cookies!(Tesla.Env.t()) :: [String.t()]
  def fetch_cookies!(%Tesla.Env{} = env) do
    fetch_headers!(env, "set-cookie")
  end

  @spec fetch_cookie!(Tesla.Env.t()) :: String.t()
  def fetch_cookie!(%Tesla.Env{} = env) do
    fetch_header!(env, "set-cookie")
  end

  @spec fetch_header!(Tesla.Env.t(), String.t()) :: String.t()
  def fetch_header!(%Tesla.Env{} = env, key) do
    case Tesla.get_header(env, key) do
      nil ->
        headers = inspect(env.headers)
        raise "There's no #{key} in #{headers}"

      value ->
        value
    end
  end

  @spec fetch_headers!(Tesla.Env.t(), String.t()) :: [String.t()]
  def fetch_headers!(%Tesla.Env{} = env, key) do
    case Tesla.get_headers(env, key) do
      [] ->
        headers = inspect(env.headers)
        raise "There's no #{key} in #{headers}"

      value ->
        value
    end
  end
end
