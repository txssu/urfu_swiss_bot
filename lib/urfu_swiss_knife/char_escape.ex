defmodule UrFUSwissKnife.CharEscape do
  @moduledoc false
  @chars_need_escape [?_, ?*, ?[, ?], ?(, ?), ?~, ?`, ?>, ?#, ?+, ?-, ?=, ?|, ?{, ?}, ?., ?!]

  @spec sigil_t(String.t(), any()) :: String.t()
  def sigil_t(data, _params) do
    escape_telegram_markdown(data)
  end

  @spec sigil_i(Macro.t(), any()) :: Macro.t()
  defmacro sigil_i(data, _params) do
    Macro.prewalk(data, fn
      # credo:disable-for-next-line Credo.Check.Consistency.UnusedVariableNames
      {{:., _, _}, outer_meta, _} = ast ->
        if Keyword.get(outer_meta, :from_interpolation, false) do
          escape_markdown_fun = quote do: escape_telegram_markdown()
          inner_meta = Keyword.delete(outer_meta, :from_interpolation)

          ast
          |> put_meta(inner_meta)
          |> Macro.pipe(escape_markdown_fun, 0)
          |> put_meta(outer_meta)
        else
          ast
        end

      other ->
        other
    end)
  end

  defp put_meta(ast, meta) do
    put_elem(ast, 1, meta)
  end

  @spec escape_telegram_markdown(String.t() | {:unescape, String.t()}) :: String.t()
  def escape_telegram_markdown({:unescape, binary}) do
    binary
  end

  def escape_telegram_markdown(<<>>) do
    <<>>
  end

  def escape_telegram_markdown(<<?\\::utf8, char::utf8, rest::binary>>) do
    <<?\\::utf8, char::utf8, escape_telegram_markdown(rest)::binary>>
  end

  def escape_telegram_markdown(<<char::utf8, rest::binary>>) when char in @chars_need_escape do
    <<?\\::utf8, char::utf8, escape_telegram_markdown(rest)::binary>>
  end

  def escape_telegram_markdown(<<char::utf8, rest::binary>>) do
    <<char::utf8, escape_telegram_markdown(rest)::binary>>
  end
end
