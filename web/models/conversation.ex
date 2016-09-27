defmodule ChatterboxHost.Conversation do
  use ChatterboxHost.Web, :model

  schema "chatterbox_conversations" do
    has_many :messages, ChatterboxHost.Message
    field :closed_at, Ecto.DateTime

    timestamps
  end

  @allowed_params ~w(closed_at)
  
  def changeset(conversation, params \\ %{}) do
    conversation |>
    cast(params, @allowed_params)
  end

  def close(conversation) do
    changeset(conversation, %{closed_at: Ecto.DateTime.utc})
  end

  def ongoing(query) do
    from c in query, where: is_nil(c.closed_at)
  end

end
