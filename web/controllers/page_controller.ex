defmodule ChatterboxHost.PageController do
  use ChatterboxHost.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
