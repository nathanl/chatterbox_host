defmodule ChatterboxHost.PageController do
  use ChatterboxHost.Web, :controller

  def index(conn, _params) do
    fake_products =
    (1..100)
    |> Enum.map(&("product #{&1}"))
    render conn, "index.html", products: fake_products
  end
end
