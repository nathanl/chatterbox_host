defmodule ChatterboxPlug do
  import Plug.Conn
  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn 
    |> fetch_session
  end

end
