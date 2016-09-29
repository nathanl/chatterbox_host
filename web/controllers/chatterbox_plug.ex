defmodule ChatterboxPlug do
  import Plug.Conn
  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn 
    |> fetch_session
    |> set_chat_session_presence_cookie
  end

  defp set_chat_session_presence_cookie(conn) do
    in_chat_session? = "#{!!get_session(conn, :getting_help_in_conversation_id)}"
    # So that browser JS can know this on page load
    put_resp_cookie(conn, "in_chat_session", in_chat_session?, http_only: false)
  end
end
