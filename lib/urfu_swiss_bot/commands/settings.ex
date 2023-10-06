defmodule UrFUSwissBot.Commands.Settings do
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.InlineKeyboardMarkup

  alias UrFUSwissKnife.Accounts

  require ExGram.Dsl
  require ExGram.Dsl.Keyboard

  @settings_text """
  Вы в настройках.
  """

  @keyboard (keyboard(:inline) do
               row do
                 button("Обновить данные авторизации", callback_data: "settings-confirm-reauth")
               end

               row do
                 button("Удалить аккаунт", callback_data: "settings-confirm-delete")
               end

               row do
                 button("Меню", callback_data: "menu")
               end
             end)

  @spec confirmation_keyboard(String.t()) :: InlineKeyboardMarkup.t()
  def confirmation_keyboard(action) do
    keyboard(:inline) do
      row do
        button("✅Я передумал", callback_data: "settings")
        button("❌Точно", callback_data: action)
      end
    end
  end

  @spec handle({:callback_query, CallbackQuery.t()}, Cnt.t()) :: Cnt.t()
  def handle({:callback_query, %{data: "settings"} = callback_query}, context) do
    context
    |> answer_callback(callback_query)
    |> edit(:inline, @settings_text, reply_markup: @keyboard)
  end

  def handle({:callback_query, %{data: "settings-confirm-reauth"} = callback_query}, context) do
    context
    |> answer_callback(callback_query)
    |> edit(:inline, "Вы точно хотите повторно пройти авторизацию?",
      reply_markup: confirmation_keyboard("start-reauth")
    )
  end

  def handle({:callback_query, %{data: "settings-confirm-delete"} = callback_query}, context) do
    context
    |> answer_callback(callback_query)
    |> edit(:inline, "Вы точно хотите удалить аккаунт?",
      reply_markup: confirmation_keyboard("settings-delete")
    )
  end

  def handle({:callback_query, %{data: "settings-delete"} = callback_query}, context) do
    Accounts.delete_user(context.extra.user)

    context
    |> answer_callback(callback_query)
    |> edit(:inline, "Ваш аккаунт успешно удалён.")
  end
end