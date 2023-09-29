defmodule UrFUAPI.UBU.CommunalCharges do
  alias UrFUAPI.UBU.Auth.Token

  alias UrFUAPI.UBU.CommunalCharges.API
  alias UrFUAPI.UBU.CommunalCharges.Info

  @spec get_dates(Token.t()) :: Info.t()
  defdelegate get_dates(auth), to: API
end
