defmodule UrFUSwissBot.Middleware.HitEvent do
  @moduledoc false
  use ExGram.Middleware

  alias ExGram.Cnt
  alias UrFUSwissKnife.Metrics

  @spec call(Cnt.t(), keyword()) :: Cnt.t()
  def call(%Cnt{update: %{update_id: id, message: %{text: text, from: %{id: by_user_id}}}} = context, _opts) do
    if String.starts_with?(text, "/") do
      Metrics.hit_command(
        id: id,
        command: text,
        by_user_id: by_user_id,
        called_at: DateTime.utc_now()
      )
    end

    context
  end

  def call(%Cnt{update: %{update_id: id, callback_query: %{data: data, from: %{id: by_user_id}}}} = context, _opts) do
    [command | _args] = String.split(data, ":")

    Metrics.hit_command(
      id: id,
      command: command,
      by_user_id: by_user_id,
      called_at: DateTime.utc_now()
    )

    context
  end

  def call(context, _opts), do: context
end
