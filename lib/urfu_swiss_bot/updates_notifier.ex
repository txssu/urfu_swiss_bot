defmodule UrFUSwissBot.UpdatesNotifier do
  import ExGram.Dsl.Keyboard
  require ExGram.Dsl.Keyboard

  defp pay_keyboard(contract) do
    keyboard(:inline) do
      row do
        button("Платежи УрФУ", url: "https://pay.urfu.ru/direct?contract_number=#{contract}")
      end
    end
  end

  def update_ubu_debt(user, was, became) do
    if was.debt != became.debt do
      formatted_debt = format_debt(became.debt)

      text = """
      Обновление счёта уплаты за общежитие!
      Сейчас на счету #{formatted_debt}

      Оплатить коммунальные платежи вы всегда можете на портале «Платежи УрФУ»"
      """

      ExGram.send_message!(user.id, text, reply_markup: pay_keyboard(became.contract), bot: UrFUSwissBot.Bot.bot())
    end
  end

  @spec format_debt(integer) :: String.t()
  defp format_debt(debt)

  defp format_debt(0) do
    "нет переплаты или задолженности\\."
  end

  defp format_debt(debt) when debt > 0 do
    "задолженность #{debt}₽"
  end

  defp format_debt(debt) do
    profit = -debt
    "переплата #{profit}₽"
  end
end
