defmodule UrfuSwissKnife.Feedback do
  @moduledoc false
  alias UrfuSwissKnife.Feedback.Message
  alias UrfuSwissKnife.Repo

  @spec create_message(ExConstructor.map_or_kwlist()) :: Message.t()
  def create_message(fields) do
    Message.new(fields)
  end

  @spec get_message(integer()) :: Message.t()
  def get_message(id) do
    Repo.get(Message, id)
  end

  @spec get_message_by_forwared_id(integer()) :: Message.t()
  def get_message_by_forwared_id(forwared_id) do
    Message
    |> Repo.select(reverse: true)
    |> Enum.find(&(forwared_id in &1.forwared_ids))
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
