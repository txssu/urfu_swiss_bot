defmodule UrFUSwissKnife.Repo do
  use CubRepo

  alias UrFUSwissKnife.Accounts.User
  alias UrFUSwissKnife.Feedback.Message
  alias UrFUSwissKnife.Metrics.CommandCall

  deftable(:users, User)
  deftable(:feedback_messages, Message)
  deftable(:metric_events, CommandCall)
end
