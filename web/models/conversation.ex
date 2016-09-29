defmodule ChatterboxHost.Conversation do
  use ChatterboxHost.Web, :model
  alias ChatterboxHost.Conversation

  schema "chatterbox_conversations" do
    has_many :messages, ChatterboxHost.Message
    field :ended_at, Ecto.DateTime

    timestamps
  end

  @allowed_params ~w(ended_at)
  
  def changeset(conversation, params \\ %{}) do
    conversation |>
    cast(params, @allowed_params)
  end

  def end_now(conversation) do
    changeset(conversation, %{ended_at: Ecto.DateTime.utc})
  end

  def ended?(conversation) do
    not is_nil(conversation.ended_at)
  end

  def ongoing(query) do
    from c in query, where: is_nil(c.ended_at)
  end

  def by_timestamp(query) do
    from c in query, order_by: c.inserted_at
  end
end
