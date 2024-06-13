defmodule UrFUSwissBot.UpdatesNotifier do
  @moduledoc false

  alias UrFUSwissBot.UpdatesNotifier.BRSCache
  alias UrFUSwissBot.UpdatesNotifier.CommunalCharges
  alias UrFUSwissKnife.Accounts

  @spec update_ubu_debt(Accounts.User.t(), CommunalCharges.communal_charges(), CommunalCharges.communal_charges()) :: :ok
  defdelegate update_ubu_debt(user, was, became), to: CommunalCharges

  @spec update_brs(Accounts.User.t(), BRSCache.subject_score() | nil, BRSCache.subject_score()) :: :ok
  defdelegate update_brs(user, was, became), to: BRSCache
end
