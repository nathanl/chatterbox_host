defmodule ChatterboxHost.SetUsername do
  def init(options), do: options

  def call(conn, _options) do
    Plug.Conn.assign(conn, :username, "User #{:rand.uniform(1_000)}")
  end
end
