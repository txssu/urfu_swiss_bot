defmodule UrFUAPI.IStudent.BRS do
  alias UrFUAPI.IStudent.Auth.Token

  alias UrFUAPI.IStudent.BRS.API
  alias UrFUAPI.IStudent.BRS.Subject

  @spec get_subjects(Token.t()) :: [Subject.t()]
  defdelegate get_subjects(auth), to: API

  @spec preload_subject_scores(Token.t(), Subject.t()) :: Subject.t()
  defdelegate preload_subject_scores(auth, subject), to: API
end
