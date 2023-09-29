defmodule UrFUAPI.IStudent.Auth.Token do
  @type t :: String.t()

  @spec new(String.t()) :: t
  def new(token) do
    token
  end
end
