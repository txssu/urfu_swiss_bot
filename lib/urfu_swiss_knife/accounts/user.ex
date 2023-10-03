defmodule UrFUSwissKnife.Accounts.User do
  use TypedStruct

  @type state :: {module(), atom()}

  typedstruct enforce: true do
    field :id, integer()
    field :username, String.t() | nil
    field :password, String.t() | nil
    field :state, state | nil
    field :is_admin, boolean, default: false
  end

  use ExConstructor

  @spec set_credentials(t, String.t(), String.t()) :: t
  def set_credentials(%__MODULE__{} = user, username, password) do
    %{user | username: username, password: password}
  end

  @spec delete_credentials(t) :: t
  def delete_credentials(%__MODULE__{} = user) do
    %{user | username: nil, password: nil}
  end

  @spec set_state(t, state) :: t
  def set_state(user, state) do
    %{user | state: state}
  end

  @spec nil_state(t) :: t
  def nil_state(user) do
    %{user | state: nil}
  end
end
