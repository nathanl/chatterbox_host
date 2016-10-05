defmodule ChatterboxHost.Tag do
  use ChatterboxHost.Web, :model

  schema "chatterbox_tags" do
    field :name, :string
  end

end
