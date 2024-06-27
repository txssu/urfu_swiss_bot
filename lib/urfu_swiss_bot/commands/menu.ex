defmodule UrFUSwissBot.Commands.Menu do
  @moduledoc false
  import ExGram.Dsl.Keyboard
  import UrFUSwissBot.CommandsHelper

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.Message
  alias UrFUSwissKnife.Accounts

  require ExGram.Dsl.Keyboard

  @text """
  Вы в главном меню. Используйте кнопки для навигации.
  """

  @keyboard (keyboard(:inline) do
               row do
                 button("Расписание 🏫", callback_data: "Schedule")
                 button("БРС 🔰", callback_data: "BRS")
               end

               row do
                 button("Финансовые Сервисы 💸", callback_data: "UBU")
               end

               row do
                 button("Настройки ⚙️", callback_data: "Settings")
               end

               row do
                 button("Обратная связь ✉️", callback_data: "Feedback")
               end
             end)

  @spec handle(
          {:callback_query, CallbackQuery.t()}
          | {:text, String.t(), Message.t()}
          | {:command, atom(), Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle(_update, context) do
    redirect_to_menu(context)
  end

  @spec redirect_to_menu(Cnt.t()) :: Cnt.t()
  def redirect_to_menu(context) do
    context
    |> remove_user_state()
    |> reply(@text, reply_markup: @keyboard)
  end

  defp remove_user_state(context) do
    Accounts.remove_state(context.extra.user)

    context
  end
end
