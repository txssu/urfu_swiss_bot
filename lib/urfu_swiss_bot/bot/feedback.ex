defmodule UrFUSwissBot.Bot.Feedback do
  alias UrFUSwissBot.Bot.Menu
  alias UrFUSwissBot.Repo.FeedbackMessage
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

  def handle({:command, :reply_feedback, message}, context) do
    if context.extra.user.is_admin do
      reply_to =
        message.reply_to_message.message_id
        |> FeedbackMessage.load()

      text = "Ответ администратора: " <> message.text

      ExGram.send_message!(reply_to.from_id, text,
        bot: context.name,
        reply_to_message_id: reply_to.original_id
      )

      FeedbackMessage.delete(reply_to)

      context
      |> answer("Готово")
    else
      context
      |> answer("Эта команда доступна только администраторам")
    end
  end

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
      sended_message =
        ExGram.forward_message!(admin.id, message.chat.id, message.message_id, bot: context.name)

      FeedbackMessage.new(sended_message.message_id, message.from.id, message.message_id)
      |> FeedbackMessage.save()
    end)

    context
    |> answer("Ваше сообщение было доставлено!")
    |> Menu.menu_by_message()
  end
end
