defmodule UrFUAPI.Modeus.Persons do
  alias UrFUAPI.Modeus.Auth.Token
  alias UrFUAPI.Modeus.Client
  alias UrFUAPI.Modeus.Persons.Person

  @spec search_person(Token.t(), String.t()) :: [Person.t()]
  def search_person(auth, fullname) do
    body = %{
      "fullName" => fullname,
      "sort" => "+fullName",
      "size" => 10,
      "page" => 0
    }

    %{body: %{"_embedded" => %{"persons" => persons}}} =
      Client.post!("/people/persons/search", body, Client.headers_from_token(auth))

    Enum.map(persons, &Person.new/1)
  end
end
