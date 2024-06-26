defmodule UrfuSwissBot.Notifications do
  @moduledoc false
  alias ExGram.Model.Message

  @spec send_notification(integer(), String.t()) :: Message.t()
  def send_notification(user_id, text) do
    ExGram.send_message!(user_id, text, parse_mode: "MarkdownV2", bot: UrFUSwissBot.Bot)
  end
end
