defmodule UrFUAPI.IStudent.BRS.API do
  alias UrFUAPI.IStudent.Auth.Token

  alias UrFUAPI.IStudent.BRS.Client
  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUAPI.IStudent.BRS.SubjectScore

  @spec get_subjects(Token.t()) :: [Subject.t()]
  def get_subjects(auth) do
    %{body: body} = Client.get!("/", Client.headers(auth))

    parse_subjects(body)
  end

  @spec parse_subjects(binary()) :: [Subject.t()]
  defp parse_subjects(body) do
    body
    |> Floki.parse_document!()
    |> Floki.find(".study-in-subjects>a")
    |> Enum.map(&parse_subject/1)
  end

  @spec parse_subject(Floki.html_tree()) :: Subject.t()
  defp parse_subject(html_subject) do
    Subject.new(
      id: parse_subject_id(html_subject),
      name: parse_subject_name(html_subject),
      total: parse_subject_total(html_subject),
      grade: parse_subject_grade(html_subject)
    )
  end

  @spec parse_subject_id(Floki.html_tree()) :: pos_integer()
  defp parse_subject_id(html_subject) do
    html_subject
    |> Floki.attribute("id")
    |> List.first()
    |> String.to_integer()
  end

  @spec parse_subject_name(Floki.html_tree()) :: String.t()
  defp parse_subject_name(html_subject) do
    html_subject
    |> Floki.find(".td-0")
    |> unpack_text()
  end

  @spec parse_subject_total(Floki.html_tree()) :: float()
  defp parse_subject_total(html_subject) do
    html_subject
    |> Floki.find(".td-1")
    |> unpack_text()
    |> String.to_float()
  end

  @spec parse_subject_grade(Floki.html_tree()) :: String.t()
  defp parse_subject_grade(html_subject) do
    html_subject
    |> Floki.find(".td-2")
    |> unpack_text()
  end

  @spec preload_subject_scores(Token.t(), Subject.t()) :: Subject.t()
  def preload_subject_scores(auth, %Subject{id: object_id} = subject) do
    %{body: body} = Client.get!("/discipline?discipline_id=#{object_id}", Client.headers(auth))

    scores = parse_subject_scores(body)

    %{subject | scores: scores}
  end

  @spec parse_subject_scores(binary()) :: [SubjectScore.t()]
  defp parse_subject_scores(body) do
    body
    |> Floki.parse_document!()
    |> Floki.find(".brs-countainer")
    |> Enum.map(&parse_subject_score/1)
  end

  @spec parse_subject_score(Floki.html_tree()) :: SubjectScore.t()
  defp parse_subject_score(html_element) do
    html_subject_score = Floki.find(html_element, ".brs-h4")

    SubjectScore.new(
      name: parse_subject_score_name(html_subject_score),
      raw: parse_subject_score_raw(html_subject_score),
      multiplier: parse_subject_score_multiplier(html_subject_score),
      total: parse_subject_score_total(html_subject_score)
    )
  end

  @spec parse_subject_score_name(Floki.html_tree()) :: String.t()
  defp parse_subject_score_name(html_subject_score) do
    html_subject_score
    |> Floki.attribute("title")
    |> List.first()
    |> String.capitalize()
  end

  @spec parse_subject_score_raw(Floki.html_tree()) :: float()

  defp parse_subject_score_raw(html_subject_score) do
    html_subject_score
    |> Floki.find(".brs-blue")
    |> unpack_text()
    |> String.to_float()
  end

  @spec parse_subject_score_multiplier(Floki.html_tree()) :: float()
  defp parse_subject_score_multiplier(html_subject_score) do
    html_subject_score
    |> Floki.find(".brs-gray")
    |> unpack_text()
    |> String.to_float()
  end

  @spec parse_subject_score_total(Floki.html_tree()) :: float()
  defp parse_subject_score_total(html_subject_score) do
    html_subject_score
    |> Floki.find(".brs-green")
    |> unpack_text()
    |> Float.parse()
    |> elem(0)
  end

  @spec unpack_text(Floki.html_tree()) :: String.t()
  defp unpack_text(html_tree) do
    html_tree
    |> Floki.text()
    |> String.trim()
  end
end
