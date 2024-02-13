defmodule UrfuSwissKnife.CharEscape do
  @moduledoc false
  @chars_need_escape [?_, ?*, ?[, ?], ?(, ?), ?~, ?`, ?>, ?#, ?+, ?-, ?=, ?|, ?{, ?}, ?., ?!]

  @spec sigil_t(String.t(), any()) :: String.t()
  def sigil_t(data, _params) do
    escape_telegram_markdown(data)
  end

  @spec escape_telegram_markdown(String.t() | {:unescape, String.t()}) :: String.t()
  def escape_telegram_markdown({:unescape, binary}) do
    binary
  end

  def escape_telegram_markdown(<<>>) do
    <<>>
  end

  def escape_telegram_markdown(<<char::utf8, rest::binary>>) when char in @chars_need_escape do
    <<?\\::utf8, char::utf8, escape_telegram_markdown(rest)::binary>>
  end

  def escape_telegram_markdown(<<char::utf8, rest::binary>>) do
    <<char::utf8, escape_telegram_markdown(rest)::binary>>
  end
end
