defmodule UrFUAPI.UBU.Auth do
  alias UrFUAPI.UBU.Auth.API
  alias UrFUAPI.UBU.Auth.Token

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, any()}
  defdelegate sign_in(username, password), to: API
end
