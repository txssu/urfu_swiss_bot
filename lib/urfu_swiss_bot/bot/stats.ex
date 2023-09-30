defmodule UrFUSwissBot.Bot.Stats do
  import ExGram.Dsl

  alias ExGram.Cnt
  alias ExGram.Model.Message

  alias UrFUSwissBot.Repo.User

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  @spec handle(
          {:command, :stats, Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle({:command, :stats, _message}, context) do
    if context.extra.user.is_admin do
      {inactive_users, active_users} =
        Enum.split_with(User.select(), fn x -> is_nil(x.username) end)

      active_users_count = Enum.count(active_users)
      active_users_stat = "Активных пользователей: #{active_users_count}"

      inactive_users_count = Enum.count(inactive_users)
      inactive_users_stat = "Неактивных пользователей: #{inactive_users_count}"

      message =
        Enum.join([active_users_stat, inactive_users_stat], "\n")

      answer(context, message)
    else
      answer(context, "Эта команда доступна только администраторам")
    end
  end
end
