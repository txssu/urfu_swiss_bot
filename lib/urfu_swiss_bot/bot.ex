defmodule UrFUSwissBot.Bot do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.Message
  alias UrFUSwissBot.Commands

  require Logger

  @callback_context Commands

  command "start"
  command "menu", description: "Вызвать меню"
  command "brs", description: "Вызвать БРС"
  command "reply_feedback"
  command "stats"

  middleware ExGram.Middleware.IgnoreUsername
  middleware UrFUSwissBot.Middleware.GetUser
  middleware UrFUSwissBot.Middleware.HitEvent
  middleware UrFUSwissBot.Middleware.UserRecovering
  middleware UrFUSwissBot.Middleware.ClearState

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
      _other -> Commands.Menu.handle(update, context)
    end
  end

  ###############################################
  # Auth
  ###############################################

  def handle(event, %Cnt{extra: %{user: nil}} = context) do
    Commands.Start.handle(event, context)
  end

  def handle(event, %Cnt{extra: %{user: %{username: nil, password: nil}}} = context) do
    Commands.Start.handle(event, context)
  end

  ###############################################
  # Commands
  ###############################################

  def handle({:command, command, _message} = event, context) when command in [:start, :menu] do
    Commands.Menu.handle(event, context)
  end

  def handle({:command, :brs, _message} = event, context) do
    Commands.BRS.handle(event, context)
  end

  def handle({:command, :reply_feedback, _message} = event, context) do
    Commands.Feedback.handle(event, context)
  end

  def handle({:command, :stats, _message} = event, context) do
    Commands.Stats.handle(event, context)
  end

  def handle({:command, "brsinfo_" <> _text, _message} = update, context) do
    Commands.BRS.handle(update, context)
  end

  def handle({:command, _unknown, _message}, context) do
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

  def handle(update, context) do
    data = inspect(update, limit: :infinity)
    Logger.warning("Unhandled update: #{data}")
    context
  end

  defp module_concat(left, right) do
    {:ok, Module.safe_concat(left, right)}
  rescue
    ArgumentError -> :error
  end
end
