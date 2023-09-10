defmodule UrFUSwissBot.Modeus.Models.Event do
  defstruct ~w[name color type starts_at ends_at address]a

  @type t :: %__MODULE__{
          name: String.t(),
          color: String.t(),
          type: String.t(),
          starts_at: DateTime.t(),
          ends_at: DateTime.t(),
          address: String.t()
        }

  @spec to_string(t) :: String.t()
  def to_string(%__MODULE__{} = event) do
    time = "#{format_datetime(event.starts_at)} – #{format_datetime(event.ends_at)}"

    [time, event.color <> event.name, event.type, event.address]
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
    |> Enum.join("\n")
  end

  defp format_datetime(datetime) do
    datetime
    |> DateTime.shift_zone!("Asia/Yekaterinburg")
    |> Calendar.strftime("%H:%M")
  end

  def impending?(%__MODULE__{starts_at: starts_at}, datetime) do
    impending_at = DateTime.add(starts_at, -90, :minute)

    DateTime.after?(datetime, impending_at) and DateTime.before?(datetime, starts_at)
  end

  def ongoing?(%__MODULE__{starts_at: starts_at, ends_at: ends_at}, datetime) do
    DateTime.after?(datetime, starts_at) and DateTime.before?(datetime, ends_at)
  end
end
