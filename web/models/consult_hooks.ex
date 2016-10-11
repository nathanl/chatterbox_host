defmodule Consult.Hooks do
  alias ChatterboxHost.{Repo,User}
  use ChatterboxHost.Web, :controller # TODO - use Plug.Conn?

  def user_for_session(conn) do
    conn = conn |> fetch_session
    user = with user_id when is_integer(user_id) <- (conn |> get_session(:user_id)),
    do: Repo.get_by(User, id: user_id)

    case user do
      %User{} -> %{id: user.id, name: user.name, cs_rep: user.cs_rep}
      _       -> %{id: nil,     name: nil,       cs_rep: false}
    end
  end

  def representative?(user) do
    !!user.cs_rep
  end

  defmacro repo do
    ChatterboxHost.Repo
  end

  defmacro endpoint do
    ChatterboxHost.Endpoint
  end

  # default implementation
  # def representative?(user) do
  #   true
  # end

  # default implementation
  # defmacro repo do
  #   MyApplicationName.Repo
  # end

  # default implementation
  # defmacro endpoint do
  #   MyApplicationName.Endpoint
  # end

  # default implementation
  # def user_for_session(conn) do
  #   %{id: nil,     name: nil}
  # end

end
