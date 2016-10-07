defmodule ChatterboxHost.CsPanelChannel do
  use Phoenix.Channel
  alias ChatterboxHost.{Repo,Conversation,Message}
  require Ecto.Query

  # TODO - send panel updates when conversations are added, deleted, or modified in the database, like this:
  # ChatterboxHost.Endpoint.broadcast("cs_panel", "panel_update", %{body: "the new view contents"})

  def join("cs_panel", _params, socket) do
    send(self, {:after_join, "the initial page contents"})
    {:ok, socket}
  end

  def handle_info({:after_join, message}, socket) do
    push(socket, "panel_update", %{body: message})
    {:noreply, socket}
  end

end
