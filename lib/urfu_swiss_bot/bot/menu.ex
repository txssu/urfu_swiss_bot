defmodule UrFUSwissBot.Bot.Menu do
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.Message

  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.Accounts.User

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  @text """
  Вы в главном меню. Используйте кнопки для навигации.
  """

  @keyboard (keyboard(:inline) do
               row do
                 button("Расписание 🏫", callback_data: "schedule")
                 button("БРС 🔰", callback_data: "brs")
               end

               row do
                 button("Финансовые Сервисы 💸", callback_data: "ubu")
               end

               row do
                 button("Настройки ⚙️", callback_data: "settings")
               end

               row do
                 button("Обратная связь ✉️", callback_data: "feedback")
               end
             end)

  @spec handle(
          {:callback_query, CallbackQuery.t()}
          | {:text, String.t(), Message.t()}
          | {:command, atom(), Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle({:callback_query, _}, context), do: menu_by_editing(context)

  def handle(_event, context), do: menu_by_message(context)

  @spec menu_by_editing(Cnt.t()) :: Cnt.t()
  def menu_by_editing(context) do
    remove_state(context.extra.user)

    edit(context, :inline, @text, reply_markup: @keyboard)
  end

  @spec menu_by_message(Cnt.t()) :: Cnt.t()
  def menu_by_message(context) do
    answer(context, @text, reply_markup: @keyboard)
  end

  @spec remove_state(User.t()) :: :ok
  defp remove_state(user) do
    user
    |> User.nil_state()
    |> Accounts.save_user()

    :ok
  end
end
