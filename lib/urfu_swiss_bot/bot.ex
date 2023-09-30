defmodule UrFUSwissBot.Bot do
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.Message
  alias ExGram.Cnt
  alias UrFUSwissBot.Bot
  alias UrFUSwissBot.Repo.User

  @bot :urfu_swiss_bot

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command "start"
  command "menu", description: "Вызвать меню"
  command "reply_feedback"

  middleware ExGram.Middleware.IgnoreUsername
  middleware UrFUSwissBot.Bot.Middleware.GetUser

  @spec bot :: :urfu_swiss_bot
  def bot, do: @bot

  ###############################################
  # Handle state
  ###############################################

  @spec handle(
          {:text, String.t(), Message.t()}
          | {:callback_query, CallbackQuery.t()}
          | {:command, atom(), Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle({:text, _text, _message} = event, %Cnt{extra: %{user: %User{}}} = context) do
    user = context.extra.user

    {module, state} = user.state

    module.handle(state, event, context)
  end

  ###############################################
  # Auth
  ###############################################

  def handle({:command, :start, _message} = event, context) do
    Bot.StartCommand.handle(event, context)
  end

  def handle(event, %Cnt{extra: %{user: nil}} = context) do
    Bot.StartCommand.handle(event, context)
  end

  def handle(event, %Cnt{extra: %{user: %User{username: nil, password: nil}}} = context) do
    Bot.StartCommand.handle(event, context)
  end

  ###############################################
  # Commands
  ###############################################

  def handle({:command, :menu, _message} = event, context) do
    Bot.Menu.handle(event, context)
  end

  def handle({:command, :reply_feedback, _message} = event, context) do
    Bot.Feedback.handle(event, context)
  end

  ###############################################
  # Callbacks
  ###############################################

  def handle({:callback_query, %{data: "start" <> _}} = event, context) do
    Bot.StartCommand.handle(event, context)
  end

  def handle({:callback_query, %{data: "menu" <> _}} = event, context) do
    Bot.Menu.handle(event, context)
  end

  def handle({:callback_query, %{data: "schedule" <> _}} = event, context) do
    Bot.Schedule.handle(event, context)
  end

  def handle({:callback_query, %{data: "settings" <> _}} = event, context) do
    Bot.Settings.handle(event, context)
  end

  def handle({:callback_query, %{data: "feedback" <> _}} = event, context) do
    Bot.Feedback.handle(event, context)
  end

  def handle({:callback_query, %{data: "brs" <> _}} = event, context) do
    Bot.BRS.handle(event, context)
  end

  def handle({:callback_query, %{data: "ubu" <> _}} = event, context) do
    Bot.UBU.handle(event, context)
  end
end
