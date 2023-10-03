defmodule UrFUSwissKnife.Metrics do
  alias UrFUSwissKnife.Repo
  alias UrFUSwissKnife.Metrics.CommandCall

  @spec hit_event(ExConstructor.map_or_kwlist()) :: :ok
  def hit_event(fields) do
    event = CommandCall.new(fields)

    Repo.save(event)
  end
end
