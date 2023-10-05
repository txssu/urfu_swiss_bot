defmodule UrFUSwissBot.Bot.Stats do
  import ExGram.Dsl

  alias UrFUSwissBot.Utils

  alias ExGram.Cnt
  alias ExGram.Model.Message

  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.Metrics

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  @spec handle(
          {:command, :stats, Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle({:command, :stats, _message}, context) do
    if context.extra.user.is_admin do
      message = Enum.join([users_stats(), commands_usage_stats()], "\n\n")
      answer(context, message, parse_mode: "MarkdownV2")
    else
      answer(context, "Эта команда доступна только администраторам")
    end
  end

  @spec users_stats :: String.t()
  def users_stats do
    {inactive_users, active_users} =
      Enum.split_with(Accounts.get_users(), fn x -> is_nil(x.username) end)

    active_users_count = Enum.count(active_users)
    active_users_stat = "Активных пользователей: #{active_users_count}"

    inactive_users_count = Enum.count(inactive_users)
    inactive_users_stat = "Неактивных пользователей: #{inactive_users_count}"

    Enum.map_join(
      [{:unescape, "*Статистика пользователей*"}, active_users_stat, inactive_users_stat],
      "\n",
      &Utils.escape_telegram_markdown/1
    )
  end

  @spec commands_usage_stats() :: String.t()
  defp commands_usage_stats do
    usage =
      Metrics.commands_usage()
      |> Enum.sort_by(fn {_command, count} -> count end)
      |> Enum.map_join("\n", fn {command, count} -> "#{command}: #{count}" end)
      |> Utils.escape_telegram_markdown()

    "*Статистика команд*\n#{usage}"
  end
end
