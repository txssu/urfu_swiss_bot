defmodule UrFUSwissBot.CommandsHelper do
  @moduledoc false

  import ExGram.Dsl

  alias ExGram.Cnt

  @spec reply(Cnt.t(), String.t(), Keyword.t()) :: Cnt.t()
  def reply(context, text, options) do
    case context.update.callback_query do
      nil -> answer(context, text, options)
      _otherwise -> edit(context, :inline, text, options)
    end
  end
end
