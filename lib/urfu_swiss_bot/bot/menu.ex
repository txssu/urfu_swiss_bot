defmodule UrFUSwissBot.Bot.Menu do
  alias UrFUSwissBot.Repo.User
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
               end
             end)

  def handle(event, context) do
    f =
      case elem(event, 0) do
        :callback_query -> &edit(&1, :inline, &2, &3)
        type when type in [nil, :command] -> &answer/3
      end

    context.extra.user
    |> User.nil_state()
    |> User.save()

    f.(context, @text, reply_markup: @keyboard)
  end

  def redirect(context) do
    handle({nil}, context)
  end
end
