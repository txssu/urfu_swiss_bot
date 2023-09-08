defmodule UrFUSwissBot.Modeus.Models.Event do
  defstruct ~w[name color type starts_at ends_at address]a

  @type t :: %__MODULE__{
    name: String.t(),
    color: String.t(),
    type: String.t(),
    starts_at: Datetime.t(),
    ends_at: Datetime.t(),
    address: String.t()
  }

  @spec to_string(t) :: String.t()
  def to_string(%__MODULE__{} = event) do
    time = "#{format_datetime(event.starts_at)} – #{format_datetime(event.ends_at)}"

    [event.color <> event.name, event.type, time, event.address]
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
    |> Enum.join("\n")
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end
end
