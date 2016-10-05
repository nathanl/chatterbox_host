defmodule ChatterboxHost.PageControllerTest do
  use ChatterboxHost.ConnCase

  test "GET / lists some products", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "product 1"
    assert html_response(conn, 200) =~ "product 10"
  end
end
