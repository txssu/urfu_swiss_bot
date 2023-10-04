defmodule UrFUSwissBot.Bot.UBU do
  import ExGram.Dsl
  import ExGram.Dsl.Keyboard

  alias ExGram.Cnt
  alias ExGram.Model.CallbackQuery
  alias ExGram.Model.InlineKeyboardMarkup

  alias UrFUSwissBot.UBU

  alias UrFUSwissKnife.Accounts.User

  require ExGram.Dsl
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

  @spec pay_keyboard(String.t()) :: InlineKeyboardMarkup.t()
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

  @spec handle({:callback_query, CallbackQuery.t()}, Cnt.t()) :: Cnt.t()
  def handle({:callback_query, %{data: "ubu"}}, context) do
    edit(context, :inline, "Что вас интересует?", reply_markup: @keyboard)
  end

  def handle({:callback_query, %{data: "ubu-check-charges"}}, context) do
    {kbd, response} = get_response(context.extra.user)

    edit(context, :inline, response, reply_markup: kbd)
  end

  @spec get_response(User.t()) :: {InlineKeyboardMarkup.t(), String.t()}
  def get_response(user) do
    {:ok, auth} = UBU.auth_user(user)
    %{debt: debt, contract: contract} = UBU.get_dates(auth)

    {pay_keyboard(contract), format_debt(debt) <> @pay_urfu_ru_ad}
  end

  @spec format_debt(integer) :: String.t()
  defp format_debt(debt)

  defp format_debt(0) do
    "Задолженности и переплаты на текущий момент нет\\."
  end

  defp format_debt(debt) when debt > 0 do
    "Задолженность на текущий момент: #{debt}₽"
  end

  defp format_debt(debt) do
    profit = -debt
    "Переплата на текущий момент: #{profit}₽"
  end
end
