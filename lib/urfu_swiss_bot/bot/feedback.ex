defmodule UrFUSwissBot.Bot.Feedback do
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.Message

  alias UrFUSwissBot.Bot.Menu
  alias UrFUSwissBot.Repo.FeedbackMessage
  alias UrFUSwissBot.Repo.User

  require ExGram.Dsl
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

  @spec handle(
          {:callback_query, CallbackQuery.t()}
          | {:command, :reply_feedback, Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle({:command, :reply_feedback, message}, context) do
    if context.extra.user.is_admin do
      reply_to =
        FeedbackMessage.load(message.reply_to_message.message_id)

      text = "Ответ администратора: " <> message.text

      ExGram.send_message!(reply_to.from_id, text,
        bot: context.name,
        reply_to_message_id: reply_to.original_id
      )

      FeedbackMessage.delete(reply_to)

      answer(context, "Готово")
    else
      answer(context, "Эта команда доступна только администраторам")
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

  @spec handle(:send_feedback, {:text, String.t(), Message.t()}, Cnt.t()) :: Cnt.t()
  def handle(:send_feedback, {:text, _text, message}, context) do
    Enum.each(User.select_admins(), fn admin ->
      sended_message =
        ExGram.forward_message!(admin.id, message.chat.id, message.message_id, bot: context.name)

      feedback_message =
        FeedbackMessage.new(sended_message.message_id, message.from.id, message.message_id)

      FeedbackMessage.save(feedback_message)
    end)

    context
    |> answer("Ваше сообщение было доставлено!")
    |> Menu.menu_by_message()
  end
end
