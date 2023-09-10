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
                 button("Обновить данные авторизации", callback_data: "settings-confirm-auth")
               end

               row do
                 button("Меню", callback_data: "menu")
               end
             end)

  @keyboard_confirm_reauth (keyboard(:inline) do
                              row do
                                button("Точно", callback_data: "start-reauth")
                              end

                              row do
                                button("Я передумал", callback_data: "settings")
                              end
                            end)

  def handle({:callback_query, %{data: "settings"} = callback_query}, context) do
    context
    |> answer_callback(callback_query)
    |> edit(:inline, @settings_text, reply_markup: @keyboard)
  end

  def handle({:callback_query, %{data: "settings-confirm-auth"} = callback_query}, context) do
    context
    |> answer_callback(callback_query)
    |> edit(:inline, "Точно?", reply_markup: @keyboard_confirm_reauth)
  end
end
