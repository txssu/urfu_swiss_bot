defmodule UrFUSwissBot.IStudent.Models.ObjectScore do
  defstruct ~w[name blue gray green]a

  def new(fields) do
    fields =
      fields
      |> Keyword.update!(:name, &String.capitalize/1)

    struct!(__MODULE__, fields)
  end

  def to_string(%__MODULE__{name: name, blue: blue, gray: gray, green: green}) do
    "#{name} - #{blue} × #{gray} = #{green}"
  end
end
