defmodule UrFUSwissBot.Middleware.GetUser do
  @moduledoc false
  use ExGram.Middleware

  alias ExGram.Cnt
  alias UrFUSwissKnife.Accounts

  @spec call(Cnt.t(), keyword()) :: Cnt.t()
  def call(%Cnt{update: %{message: %{from: %{id: id}}}} = context, _opts) do
    add_extra(context, :user, Accounts.get_user(id))
  end

  def call(%Cnt{update: %{callback_query: %{from: %{id: id}}}} = context, _opts) do
    add_extra(context, :user, Accounts.get_user(id))
  end

  def call(context, _opts), do: context
end
