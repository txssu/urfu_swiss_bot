defmodule UrFUSwissBot.Bot do
  alias UrFUSwissBot.Repo.User
  alias ExGram.Cnt
  alias UrFUSwissBot.Bot

  @bot :urfu_swiss_bot

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command "start"
  command "menu", description: "Вызвать меню"

  middleware ExGram.Middleware.IgnoreUsername
  middleware UrFUSwissBot.Bot.Middleware.GetUser

  def bot, do: @bot

  def handle({:command, :start, _message} = event, context) do
    Bot.StartCommand.handle(event, context)
  end

  def handle(event, %Cnt{extra: %{user: nil}} = context) do
    Bot.StartCommand.handle(event, context)
  end

  def handle(event, %Cnt{extra: %{user: %User{username: nil, password: nil}}} = context)
      when elem(event, 0) in [:command, :callback_query] do
    Bot.StartCommand.handle(event, context)
  end

  def handle({:command, :menu, _message} = event, context) do
    Bot.Menu.handle(event, context)
  end

  def handle({:text, _text, _message} = event, context) do
    user = context.extra.user

    {module, state} = user.state

    module.handle(state, event, context)
  end

  def handle({:callback_query, %{data: "menu" <> _}} = event, context) do
    Bot.Menu.handle(event, context)
  end

  def handle({:callback_query, %{data: "schedule" <> _}} = event, context) do
    Bot.Schedule.handle(event, context)
  end
end
