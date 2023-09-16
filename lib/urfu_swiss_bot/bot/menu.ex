defmodule UrFUSwissBot.Bot.Menu do
  import ExGram.Dsl
  require ExGram.Dsl

  import ExGram.Dsl.Keyboard
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
                 button("Настройки 📝", callback_data: "settings")
               end

               row do
                 button("Обратная связь ✉️", callback_data: "feedback")
               end
             end)

  def handle({:callback_query, _}, context), do: menu_by_editing(context)

  def handle(_, context), do: menu_by_message(context)

  def menu_by_editing(context) do
    edit(context, :inline, @text, reply_markup: @keyboard)
  end

  def menu_by_message(context) do
    answer(context, @text, reply_markup: @keyboard)
  end
end
