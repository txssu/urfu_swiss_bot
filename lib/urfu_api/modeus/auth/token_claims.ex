defmodule UrFUAPI.Modeus.Auth.TokenClaims do
  use TypedStruct

  typedstruct enforce: true do
    field(:external_person_id, String.t())
    field(:at_hash, String.t())
    field(:aud, [String.t()])
    field(:azp, String.t())
    field(:exp, DateTime.t())
    field(:iat, DateTime.t())
    field(:iss, String.t())
    field(:nonce, String.t())
    field(:person_id, String.t())
    field(:preferred_username, String.t())
    field(:sub, String.t())
  end

  use ExConstructor, :do_new

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> do_new()
    |> to_datetime(:exp)
    |> to_datetime(:iat)
  end

  @spec to_datetime(t(), atom()) :: t()
  def to_datetime(claims, key) do
    Map.update!(claims, key, &DateTime.from_unix!/1)
  end
end
