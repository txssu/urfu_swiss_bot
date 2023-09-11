defmodule UrFUSwissBot.Bot.Settings do
  import ExGram.Dsl
  require ExGram.Dsl

  import ExGram.Dsl.Keyboard
  require ExGram.Dsl.Keyboard

  @settings_text """
  Вы в настройках.
  """

  @keyboard (keyboard(:inline) do
               row do
                 button("Обновить данные авторизации", callback_data: "settings-confirm-reauth")
               end

               row do
                 button("Меню", callback_data: "menu")
               end
             end)

  def confirmation_keyboard(action) do
    keyboard(:inline) do
      row do
        button("✅Я передумал", callback_data: "settings")
        button("❌Точно", callback_data: action)
      end
    end
  end

  def handle({:callback_query, %{data: "settings"} = callback_query}, context) do
    context
    |> answer_callback(callback_query)
    |> edit(:inline, @settings_text, reply_markup: @keyboard)
  end

  def handle({:callback_query, %{data: "settings-confirm-reauth"} = callback_query}, context) do
    context
    |> answer_callback(callback_query)
    |> edit(:inline, "Точно?", reply_markup: confirmation_keyboard("start-reauth"))
  end
end
