defmodule ChatterboxHost.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do

    create table(:users) do
      add :name, :string
      add :email, :string, null: false
      add :password_hash, :string
      add :cs_rep, :boolean, default: false

      timestamps
    end

    create unique_index(:users, :email)
  end
end
