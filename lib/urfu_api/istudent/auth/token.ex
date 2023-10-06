defmodule UrFUAPI.IStudent.Auth.Token do
  use TypedStruct

  typedstruct enforce: true do
    field :access_token, String.t()
    field :username, String.t()
  end

  @spec new(String.t(), String.t()) :: t
  def new(token, username) do
    %__MODULE__{username: username, access_token: token}
  end
end
