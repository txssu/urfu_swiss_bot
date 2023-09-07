# Used by "mix format"
[
  import_deps: [:tesla],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    # import from ex_gram
    command: 1,
    command: 2,
    middleware: 1,
    answer: 2,
    answer: 3,
    answer: 4,
    edit: 5,
    row: 1,
    button: 1,
    button: 2
  ]
]
