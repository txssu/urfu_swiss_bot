defmodule UrFUSwissBot.Bot.Feedback do
  alias UrFUSwissBot.Repo.User
  import ExGram.Dsl
  require ExGram.Dsl

  import ExGram.Dsl.Keyboard
  require ExGram.Dsl.Keyboard

  @text """
  Здесь вы можете задать вопрос, оставить предложение или сообщить об ошибке. \
  Просто отправьте любое сообщение.
  """

  @keyboard (keyboard(:inline) do
               row do
                 button("В меню", callback_data: "menu")
               end
             end)

  def handle({:callback_query, %{data: "feedback"} = callback_query}, context) do
    context.extra.user
    |> User.set_state({__MODULE__, :send_feedback})
    |> User.save()

    context
    |> answer_callback(callback_query)
    |> edit(:inline, @text, reply_markup: @keyboard)
  end

  def handle(:send_feedback, {:text, _text, message}, context) do
    User.select_admins()
    |> Enum.each(fn admin ->
      ExGram.forward_message!(admin.id, message.chat.id, message.message_id, bot: context.name)
    end)

    context
    |> answer("Ваше сообщение было доставлено!")
    |> UrFUSwissBot.Bot.Menu.menu_by_message()
  end
end
