defmodule UrFUAPI.UBU.CommunalCharges do
  alias UrFUAPI.UBU.Auth.Token
  alias UrFUAPI.UBU.CommunalCharges.Client
  alias UrFUAPI.UBU.CommunalCharges.Info
  alias UrFUAPI.UBU.Client

  @spec get_dates(Token.t()) :: Info.t()
  def get_dates(auth) do
    %{body: %{"result" => result}} = Client.exec(auth, "CommunalCharges.GetDates")

    Info.new(result)
  end
end
