defmodule UrfuSwissBot.Bot do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.Message
  alias UrfuSwissBot.Commands

  require Logger

  @callback_context Commands

  command "start"
  command "menu", description: "Вызвать меню"
  command "reply_feedback"
  command "stats"

  middleware ExGram.Middleware.IgnoreUsername
  middleware UrfuSwissBot.Middleware.GetUser
  middleware UrfuSwissBot.Middleware.HitEvent
  middleware UrfuSwissBot.Middleware.UserRecovering

  @spec bot :: __MODULE__
  def bot, do: __MODULE__

  @spec handle(
          {:text, String.t(), Message.t()}
          | {:callback_query, CallbackQuery.t()}
          | {:command, atom(), Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle(update, context)

  ###############################################
  # Recover after deleting
  ###############################################

  def handle(event, %Cnt{extra: %{is_recover: true}} = context) do
    Commands.Start.handle(event, context)
  end

  ###############################################
  # Handle state
  ###############################################

  def handle({:text, _text, _message} = update, context) do
    %{extra: %{user: %{state: state}}} = context

    case state do
      :auth -> Commands.Auth.handle(update, context)
      :sending_schedule_date -> Commands.Schedule.handle(update, context)
      :sending_feeback -> Commands.Feedback.handle(update, context)
    end
  end

  ###############################################
  # Auth
  ###############################################

  def handle({:command, :start, _message} = event, %Cnt{extra: %{user: user}} = context) do
    Commands.Start.handle(event, context)

    case user do
      nil -> Commands.Start.handle(event, context)
      %{username: nil, password: nil} -> Commands.Start.handle(event, context)
      _already_authed -> Commands.Menu.handle(event, context)
    end
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

  def handle({:callback_query, %{data: callback}} = event, context) do
    callback_module_name = callback |> String.split(".") |> hd()

    case module_concat(@callback_context, callback_module_name) do
      {:ok, module} ->
        module.handle(event, context)

      :error ->
        not_found_module = "#{@callback_context}.#{callback_module_name}"
        Logger.error(~s(Cannot find #{not_found_module} for callback query "#{callback}".))

        Commands.Menu.handle(event, context)
    end
  end

  defp module_concat(left, right) do
    {:ok, Module.safe_concat(left, right)}
  rescue
    ArgumentError -> :error
  end
end
