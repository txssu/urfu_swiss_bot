defmodule UrfuSwissBot.Middleware.UserRecovering do
  @moduledoc false
  use ExGram.Middleware

  alias ExGram.Cnt
  alias UrFUSwissKnife.Accounts.User

  @spec call(Cnt.t(), []) :: Cnt.t()
  def call(%Cnt{extra: %{user: %User{is_deleted: true}}} = context, _opts) do
    add_extra(context, :is_recover, true)
  end

  def call(context, _opts), do: context
end
