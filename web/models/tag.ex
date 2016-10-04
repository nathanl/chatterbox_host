defmodule ChatterboxHost.Tag do
  use ChatterboxHost.Web, :model

  schema "chatterbox_tags" do
    field :name, :string
  end

  # TODO read up on testing in Phoenix and TDD this
  def changeset_to_update(conversation, tag_ids) do
  end

end
