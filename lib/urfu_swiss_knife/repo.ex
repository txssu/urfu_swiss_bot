defmodule UrfuSwissKnife.Repo do
  use CubRepo

  alias UrfuSwissKnife.Accounts.User
  alias UrfuSwissKnife.Feedback.Message
  alias UrfuSwissKnife.Metrics.CommandCall
  alias UrfuSwissKnife.PersistentCache.CommunalCharges

  deftable(:users, User)
  deftable(:feedback_messages, Message)
  deftable(:metric_command_calls, CommandCall)
  deftable(:communal_charges, CommunalCharges)
end
