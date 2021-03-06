defmodule ChatterboxHost.Message do
  use ChatterboxHost.Web, :model
  alias ChatterboxHost.Message

  schema "chatterbox_messages" do

    belongs_to :conversation, ChatterboxHost.Conversation
    field :content, :string # limit to ~3k?
    field :sender_name, :string
    field :sender_id, :integer

    timestamps
  end

  @required_fields ~w(conversation_id, content, sender_name)
  @allowed_fields @required_fields ++ ~w(sender_id)
  @max_content_size 4096 # arbitrary
  
  def changeset(model, params \\ %{}) do
    model
    # TODO fix casting - doesn't understand conversation_id
    # |> cast(params, @allowed_fields)
    # |> validate_required(@required_fields)
    # |> validate_length(:content, max: @max_content_size)
  end

  def sequential(query) do
    from c in query, order_by: [asc: c.id]
  end

  def reverse_sequential(query) do
    from c in query, order_by: [desc: c.id]
  end

end
