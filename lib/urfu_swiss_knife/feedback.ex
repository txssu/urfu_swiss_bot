defmodule UrFUSwissKnife.Feedback do
  alias UrFUSwissKnife.Repo

  alias UrFUSwissKnife.Feedback.Message

  @spec create_message(integer(), integer(), integer()) :: Message.t()
  def create_message(id, from_id, original_id) do
    Message.new(id, from_id, original_id)
  end

  @spec get_message(integer()) :: Message.t()
  def get_message(id) do
    Repo.get(Message, id)
  end

  @spec save_message(Message.t()) :: Message.t()
  def save_message(message) do
    :ok = Repo.save(message)

    message
  end

  @spec delete_message(Message.t()) :: :ok
  def delete_message(message) do
    Repo.delete(message)
  end
end
