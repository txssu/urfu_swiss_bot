defmodule UrFUSwissBot.Bot.BRS do
  alias UrFUSwissBot.IStudent

  import ExGram.Dsl
  require ExGram.Dsl

  import ExGram.Dsl.Keyboard
  require ExGram.Dsl.Keyboard


  @keyboard (keyboard(:inline) do
    row do
      button("В меню", callback_data: "menu")
    end
  end)

  def handle({:callback_query, %{data: "brs"}}, context) do
    response = get_response(context.extra.user)

    context
    |> answer(response, reply_markup: @keyboard, parse_mode: "MarkdownV2")
  end

  def get_response(user) do
    auth = IStudent.Auth.auth(user.username, user.password)
    objects = IStudent.BRS.get_objects(auth)

    Enum.map_join(objects, "\n\n", &IStudent.Models.Object.to_string/1)
  end
end
