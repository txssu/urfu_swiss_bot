defmodule UrFUSwissBot.IStudent.BRS do
  alias UrFUSwissBot.Cache
  alias UrFUSwissBot.IStudent.Models.Object
  alias UrFUSwissBot.IStudent.Models.ObjectScore

  use Nebulex.Caching
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://istudent.urfu.ru/s/http-urfu-ru-ru-students-study-brs"

  @decorate cacheable(cache: Cache, key: auth, ttl: :timer.hours(1))
  def get_objects(auth) do
    %{body: body} = get!("/", auth_to_headers(auth))

    body
    |> Floki.parse_document!()
    |> Floki.find(".study-in-subjects>a")
    |> Enum.map(&to_object(&1, auth))
  end

  defp to_object(html_element, auth) do
    id =
      html_element
      |> elem(1)
      |> Enum.into(%{})
      |> Map.fetch!("id")
      |> String.to_integer()

    name = Floki.find(html_element, ".td-0") |> unpack_text()
    score = Floki.find(html_element, ".td-1") |> unpack_text() |> String.to_float()
    grade = Floki.find(html_element, ".td-2") |> unpack_text()
    scores = get_object_scores(auth, id)

    Object.new(
      id: id,
      name: name,
      score: score,
      grade: grade,
      scores: scores
    )
  end

  def get_object_scores(auth, object_id) do
    %{body: body} = get!("/discipline?discipline_id=#{object_id}", auth_to_headers(auth))

    body
    |> Floki.parse_document!()
    |> Floki.find(".brs-countainer")
    |> Enum.map(&to_object_scores/1)
  end

  defp to_object_scores(html_element) do
    header = Floki.find(html_element, ".brs-h4")

    name = Floki.attribute(header, "title") |> List.first()
    blue = Floki.find(header, ".brs-blue") |> unpack_text() |> String.to_float()
    gray = Floki.find(header, ".brs-gray") |> unpack_text() |> String.to_float()
    {green, _} = Floki.find(header, ".brs-green") |> unpack_text() |> Float.parse()

    ObjectScore.new(name: name, blue: blue, gray: gray, green: green)
  end

  defp unpack_text(floki_result) do
    floki_result
    |> Floki.text()
    |> String.trim()
  end

  defp auth_to_headers(auth) do
    [headers: [{"cookie", auth}]]
  end
end
