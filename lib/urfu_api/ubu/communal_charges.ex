defmodule UrFUAPI.UBU.CommunalCharges do
  alias UrFUAPI.UBU.Auth.Token
  alias UrFUAPI.UBU.CommunalCharges.Client
  alias UrFUAPI.UBU.CommunalCharges.Info

  defmodule Client do
    alias UrFUAPI.UBU.Auth.Token
    alias UrFUAPI.UBU.Headers

    use Tesla

    plug Tesla.Middleware.BaseUrl, "https://ubu.urfu.ru/fse/api/rpc"
    plug Tesla.Middleware.JSON

    @spec exec(Token.t(), String.t()) :: Tesla.Env.t()
    def exec(auth, method_name) do
      body = %{
        method: method_name
      }

      post!("", body, Headers.from_token(auth))
    end
  end

  @spec get_dates(Token.t()) :: Info.t()
  def get_dates(auth) do
    %{body: %{"result" => result}} = Client.exec(auth, "CommunalCharges.GetDates")

    Info.new(result)
  end
end
