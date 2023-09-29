defmodule UrFUSwissBot.Bot.UBU do
  alias UrFUSwissBot.Repo.User

  alias UrFUSwissBot.UBU

  import ExGram.Dsl
  require ExGram.Dsl

  import ExGram.Dsl.Keyboard
  require ExGram.Dsl.Keyboard

  @pay_urfu_ru_ad "\n\nОплатить коммунальные платежи вы всегда можете на портале «Платежи УрФУ»"

  @keyboard (keyboard(:inline) do
               row do
                 button("Проверить задолженность за общагу", callback_data: "ubu-check-charges")
               end

               row do
                 button("В меню", callback_data: "menu")
               end
             end)

  defp pay_keyboard(contract) do
    keyboard(:inline) do
      row do
        button("Платежи УрФУ", url: "https://pay.urfu.ru/direct?contract_number=#{contract}")
      end

      row do
        button("В меню", callback_data: "menu")
      end
    end
  end

  def handle({:callback_query, %{data: "ubu"}}, context) do
    context
    |> edit(:inline, "Что вас интересует?", reply_markup: @keyboard)
  end

  def handle({:callback_query, %{data: "ubu-check-charges"}}, context) do
    {kbd, response} = get_response(context.extra.user)

    context
    |> edit(:inline, response, reply_markup: kbd)
  end

  def get_response(%User{username: username, password: password}) do
    {:ok, auth} = UBU.auth(username, password)
    %{debt: debt, contract: contract} = UBU.get_dates(auth)

    {pay_keyboard(contract), format_debt(debt) <> @pay_urfu_ru_ad}
  end

  defp format_debt(debt)

  defp format_debt(0) do
    "Задолженности и переплаты на текущий момент нет."
  end

  defp format_debt(debt) do
    "Задолженность на текущий момент: #{debt}₽"
  end
end
