defmodule ChatterboxHost.RegistrationController do
  use ChatterboxHost.Web, :controller
  alias ChatterboxHost.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case ChatterboxHost.Repo.insert(changeset) do
      {:ok, changeset} ->
        conn
        |> put_session(:user_id, changeset.id)
        |> put_flash(:info, "Your account was created")
        |> redirect(to: "/")
      {:error, changeset} ->
        conn
        |> put_flash(:info, "Unable to create account")
        |> render("new.html", changeset: changeset)
    end
  end
end
