defmodule UrFUSwissKnife.Repo do
  use CubRepo

  alias UrFUSwissKnife.Accounts.User
  alias UrFUSwissKnife.Feedback.Message

  deftable(:users, User)
  deftable(:feedback_message, Message)
end
