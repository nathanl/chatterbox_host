defmodule ChatterboxHost.Session do
  alias ChatterboxHost.User

  def login(params, repo) do
    user = repo.get_by(User, email: String.downcase(params["email"]))
    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _    -> :error
    end
  end

  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> User.check_password(user, password)
    end
  end

  def current_user(conn) do
    id = Plug.Conn.get_session(conn, :user_id)
    if id, do: ChatterboxHost.Repo.get(User, id)
  end

  def logged_in?(conn), do: !!current_user(conn)

end
