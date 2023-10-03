defmodule UrFUSwissKnife.Feedback do
  alias UrFUSwissKnife.Repo

  alias UrFUSwissKnife.Feedback.Message

  @spec create_message(ExConstructor.map_or_kwlist()) :: Message.t()
  def create_message(fields) do
    Message.new(fields)
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
