defmodule AuthServer.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  alias UrFUSwissBot.Repo.User
  alias UrFUSwissBot.Modeus.Auth
  alias UrFUSwissBot.Bot.Menu

  use Plug.Router

  # This module is a Plug, that also implements it's own plug pipeline, below:

  # Using Plug.Logger for logging request information
  plug(Plug.Logger)
  # responsible for matching routes
  plug(:match)
  # Note, order of plugs is important, by placing this _after_ the 'match' plug,
  # we will only parse the request AFTER there is a route match.
  plug(Plug.Parsers, parsers: [:urlencoded])
  # responsible for dispatching responses
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, page())
  end

  post "/" do
    %{"email" => email, "password" => password, "telegram_id" => id} = conn.params
    user = User.load(String.to_integer(id))

    case Auth.register_user(user, email, password) do
      {:ok, authed_user} ->
        User.save(authed_user)
        Menu.send_menu(authed_user.id)

        conn
        |> Plug.Conn.put_resp_header("location", "/?telegram_id=#{id}&status=ok")
        |> Plug.Conn.resp(:found, "")

      _err ->
        conn
        |> Plug.Conn.put_resp_header("location", "/?telegram_id=#{id}&status=error")
        |> Plug.Conn.resp(:found, "")
    end
  end

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end

  defp page do
    priv = :code.priv_dir(:urfu_swiss_bot)

    File.read!(Path.join(priv, "auth.html"))
  end
end
