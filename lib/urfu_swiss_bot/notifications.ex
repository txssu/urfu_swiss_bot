defmodule UrfuSwissBot.Notifications do
  @moduledoc false
  def send_notification(user_id, text) do
    ExGram.send_message!(user_id, text, parse_mode: "MarkdownV2", bot: UrFUSwissBot.Bot)
  end
end
