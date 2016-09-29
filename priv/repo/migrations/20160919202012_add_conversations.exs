defmodule ChatterboxHost.Repo.Migrations.AddConversations do
  use Ecto.Migration

  def change do
    create table(:chatterbox_conversations) do
      add :ended_at, :datetime
      timestamps
    end

    create table(:chatterbox_messages) do
      add :conversation_id, references(:chatterbox_conversations)
      add :content, :text, null: false
      add :sender_name, :string, null: false
      add :sender_id, :integer

      timestamps
    end

    create table(:chatterbox_tags) do
      add :name, :string, size: 64
    end

    create table(:chatterbox_conversations_tags) do
      add :conversation_id, references(:chatterbox_conversations)
      add :tag_id, references(:chatterbox_tags)

      timestamps
    end

  end
end
