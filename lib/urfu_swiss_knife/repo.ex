defmodule UrFUSwissKnife.Repo do
  use CubRepo

  alias UrFUSwissKnife.Accounts.User
  alias UrFUSwissKnife.Feedback.Message
  alias UrFUSwissKnife.Metrics.CommandCall
  alias UrFUSwissKnife.PersistentCache.CommunalCharges

  deftable(:users, User)
  deftable(:feedback_messages, Message)
  deftable(:metric_command_calls, CommandCall)
  deftable(:communal_charges, CommunalCharges)
end
