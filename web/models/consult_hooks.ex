defmodule Consult.Hooks do
  alias ChatterboxHost.{Repo,User}
  use ChatterboxHost.Web, :controller

  def user_for_session(conn) do
    conn = conn |> fetch_session
    user = with user_id when is_integer(user_id) <- (conn |> get_session(:user_id)),
    do: Repo.get_by(User, id: user_id)

    case user do
      %User{} -> %{id: user.id, name: user.name}
      _       -> %{id: nil,     name: "Anonymous"}
    end
  end

  # default implementation
  # def user_for_session(conn) do
  #   %{id: nil,     name: nil}
  # end

end
