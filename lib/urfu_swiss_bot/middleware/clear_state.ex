defmodule UrFUSwissBot.Middleware.ClearState do
  @moduledoc false
  use ExGram.Middleware

  alias ExGram.Cnt
  alias ExGram.Model.Message
  alias ExGram.Model.Update
  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.Accounts.User

  @spec call(Cnt.t(), keyword()) :: Cnt.t()
  # Save state if user is authenticating
  def call(%Cnt{extra: %{user: %User{state: :auth}}} = context, _opts), do: context

  # Save state if message has entities
  def call(%Cnt{update: %Update{message: %Message{entities: nil}}} = context, _opts), do: context

  # Remove state if message has command, or ignore if not
  def call(%Cnt{update: %Update{message: %Message{entities: entities}}} = context, _opts) do
    user =
      case Enum.find(entities, &(&1.type == "bot_command")) do
        nil -> context.extra.user
        _command -> Accounts.remove_state(context.extra.user)
      end

    put_in(context, [Access.key(:extra), :user], user)
  end

  def call(context, _opts), do: context
end
