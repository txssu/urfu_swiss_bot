defmodule UrFUSwissBot.Bot do
  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.Message

  alias UrFUSwissBot.Commands

  @bot :urfu_swiss_knife

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command "start"
  command "menu", description: "Вызвать меню"
  command "reply_feedback"
  command "stats"

  middleware ExGram.Middleware.IgnoreUsername
  middleware UrFUSwissBot.Middleware.GetUser
  middleware UrFUSwissBot.Middleware.HitEvent
  middleware UrFUSwissBot.Middleware.UserRecovering

  @spec bot :: :urfu_swiss_knife
  def bot, do: @bot

  ###############################################
  # Recover after deleting
  ###############################################

  def handle(event, %Cnt{extra: %{is_recover: true}} = context) do
    Commands.Start.handle(event, context)
  end

  ###############################################
  # Handle state
  ###############################################

  @spec handle(
          {:text, String.t(), Message.t()}
          | {:callback_query, CallbackQuery.t()}
          | {:command, atom(), Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle(
        {:text, _text, _message} = event,
        %Cnt{extra: %{user: %{state: {module, state}}}} = context
      ) do
    module.handle(state, event, context)
  end

  ###############################################
  # Auth
  ###############################################

  def handle({:command, :start, _message} = event, %Cnt{extra: %{user: nil}} = context) do
    Commands.Start.handle(event, context)
  end

  # already authed
  def handle({:command, :start, _message} = event, context) do
    Commands.Menu.handle(event, context)
  end

  def handle(event, %Cnt{extra: %{user: nil}} = context) do
    Commands.Start.handle(event, context)
  end

  def handle(event, %Cnt{extra: %{user: %{username: nil, password: nil}}} = context) do
    Commands.Start.handle(event, context)
  end

  ###############################################
  # Commands
  ###############################################

  def handle({:command, :menu, _message} = event, context) do
    Commands.Menu.handle(event, context)
  end

  def handle({:command, :reply_feedback, _message} = event, context) do
    Commands.Feedback.handle(event, context)
  end

  def handle({:command, :stats, _message} = event, context) do
    Commands.Stats.handle(event, context)
  end

  ###############################################
  # Not found commands
  ###############################################

  def handle({:command, _unknow, _message}, context) do
    answer(context, "Команда не найдена")
  end

  def handle({:text, _text, _message}, %Cnt{extra: %{user: %{state: nil}}} = context) do
    answer(context, "Команда не найдена")
  end

  ###############################################
  # Callbacks
  ###############################################

  def handle({:callback_query, %{data: "start" <> _}} = event, context) do
    Commands.Start.handle(event, context)
  end

  def handle({:callback_query, %{data: "menu" <> _}} = event, context) do
    Commands.Menu.handle(event, context)
  end

  def handle({:callback_query, %{data: "schedule" <> _}} = event, context) do
    Commands.Schedule.handle(event, context)
  end

  def handle({:callback_query, %{data: "settings" <> _}} = event, context) do
    Commands.Settings.handle(event, context)
  end

  def handle({:callback_query, %{data: "feedback" <> _}} = event, context) do
    Commands.Feedback.handle(event, context)
  end

  def handle({:callback_query, %{data: "brs" <> _}} = event, context) do
    Commands.BRS.handle(event, context)
  end

  def handle({:callback_query, %{data: "ubu" <> _}} = event, context) do
    Commands.UBU.handle(event, context)
  end
end
