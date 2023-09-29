defmodule UrFUAPI.IStudent.Auth do
  alias UrFUAPI.IStudent.Auth.API
  alias UrFUAPI.IStudent.Auth.Token

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, any()}
  defdelegate sign_in(username, password), to: API
end
