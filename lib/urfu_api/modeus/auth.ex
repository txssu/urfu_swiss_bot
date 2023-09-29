defmodule UrFUAPI.Modeus.Auth do
  alias UrFUAPI.Modeus.Auth.API
  alias UrFUAPI.Modeus.Auth.Token

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, any()}
  defdelegate sign_in(username, password), to: API
end
