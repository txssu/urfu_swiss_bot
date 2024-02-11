defmodule UrfuSwissBot.Commands.Feedback do
  @moduledoc false
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.Message
  alias UrfuSwissBot.Commands.Menu
  alias UrFUSwissKnife.Accounts
  alias UrFUSwissKnife.Feedback

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
          | {:command, :reply_feedback, Message.t()}
          | {:text, String.t(), Message.t()},
          Cnt.t()
        ) :: Cnt.t()
  def handle({:command, :reply_feedback, message}, context) do
    if context.extra.user.is_admin do
      reply_to =
        Feedback.get_message_by_forwared_id(message.reply_to_message.message_id)

      text = "Ответ администратора: " <> message.text

      ExGram.send_message!(reply_to.from_id, text,
        bot: context.name,
        reply_to_message_id: reply_to.id
      )

      answer(context, "Готово")
    else
      answer(context, "Эта команда доступна только администраторам")
    end
  end

  def handle({:callback_query, %{data: "feedback"} = callback_query}, context) do
    Accounts.set_sending_feedback_state(context.extra.user)

    context
    |> answer_callback(callback_query)
    |> edit(:inline, @text, reply_markup: @keyboard)
  end

  def handle({:text, text, message}, context) do
    forwared_ids =
      Accounts.get_admins()
      |> Stream.map(fn admin ->
        ExGram.forward_message!(admin.id, message.chat.id, message.message_id, bot: context.name)
      end)
      |> Enum.map(&Map.fetch!(&1, :message_id))

    feedback_message =
      Feedback.create_message(
        id: message.message_id,
        from_id: message.from.id,
        forwared_ids: forwared_ids,
        text: text
      )

    Feedback.save_message(feedback_message)

    context
    |> answer("Ваше сообщение было доставлено!")
    |> Menu.menu_by_message()
  end
end
