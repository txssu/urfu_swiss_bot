defmodule UrFUSwissBot.Bot.Middleware.GetUser do
  use ExGram.Middleware

  alias ExGram.Cnt
  alias UrFUSwissBot.Repo.User

  @spec call(Cnt.t(), keyword()) :: Cnt.t()
  def call(%Cnt{update: %{message: %{from: %{id: id}}}} = context, _opts) do
    add_extra(context, :user, User.load(id))
  end

  def call(%Cnt{update: %{callback_query: %{from: %{id: id}}}} = context, _opts) do
    add_extra(context, :user, User.load(id))
  end

  def call(context, _opts), do: context
end
