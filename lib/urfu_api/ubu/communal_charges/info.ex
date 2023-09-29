defmodule UrFUAPI.UBU.CommunalCharges.Info do
  defmodule Charge do
    use TypedStruct

    typedstruct enforce: true do
      field(:accrual, float())
      field(:payment, float())
    end

    use ExConstructor
  end

  use TypedStruct

  typedstruct enforce: true do
    field(:contract, String.t())
    field(:debt, integer())
    field(:deposit, integer())
    field(:charges, [%{integer => %{integer => Charge.t()}}])
  end

  use ExConstructor, :do_new

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> do_new()
    |> parse_charges()
  end

  @spec parse_charges(t()) :: t()
  defp parse_charges(struct) do
    Map.update!(struct, :charges, fn charges ->
      convert(charges)
    end)
  end

  @spec convert(list()) :: [Charge.t()]
  defp convert(charges) do
    charges
    |> Stream.map(fn %{"year" => value} = item ->
      months =
        item
        |> Map.fetch!("months")
        |> Stream.with_index(1)
        |> Stream.reject(fn {value, _index} -> is_nil(value) end)
        |> Stream.map(fn {value, index} -> {index, Charge.new(value)} end)
        |> Enum.into(%{})

      {value, months}
    end)
    |> Enum.into(%{})
  end
end
