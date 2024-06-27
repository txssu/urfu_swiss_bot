defmodule UrFUSwissBot.Notifications.UBUChargesFormatter do
  @moduledoc false
  import ExGram.Dsl.Keyboard
  import UrFUSwissKnife.CharEscape

  alias ExGram.Model.InlineKeyboardMarkup

  @spec format_update(integer(), integer()) :: {String.t(), InlineKeyboardMarkup.t()}
  def format_update(debt, contract) do
    formatted_debt = format_debt(debt)

    text = ~t"""
    Обновление счёта уплаты за общежитие!
    Сейчас на счету #{formatted_debt}

    Оплатить коммунальные платежи вы всегда можете на портале «Платежи УрФУ»"
    """

    {text, pay_keyboard(contract)}
  end

  defp format_debt(debt)

  defp format_debt(0) do
    "нет переплаты или задолженности."
  end

  defp format_debt(debt) when debt > 0 do
    "задолженность #{debt}₽"
  end

  defp format_debt(debt) do
    profit = -debt
    "переплата #{profit}₽"
  end

  defp pay_keyboard(contract) do
    keyboard(:inline) do
      row do
        button("Платежи УрФУ", url: "https://pay.urfu.ru/direct?contract_number=#{contract}")
      end
    end
  end
end
