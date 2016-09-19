defmodule ChatterboxHost.Repo.Migrations.AddConversations do
  use Ecto.Migration

  def change do
    create table(:chatterbox_conversations) do
      add :created_at, :datetime
      add :ended_at, :datetime
      add :user_id, :string
    end

    create table(:chatterbox_messages) do
      add :conversation_id, references(:chatterbox_conversations)
      add :sender_id, :string
      add :content, :text
      add :created_at, :datetime
    end

    create table(:chatterbox_tags) do
      add :name, :string, size: 64
    end

  end
end
