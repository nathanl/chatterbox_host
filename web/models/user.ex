defmodule ChatterboxHost.User do
  use ChatterboxHost.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :cs_rep, :boolean

    timestamps
  end

  @required_fields ~w(email password name)
  @optional_fields ~w(cs_rep)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5)
    |> put_pass_hash()
  end

  def check_password(user, password) do
    Comeonin.Bcrypt.checkpw(password, user.password_hash)
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
