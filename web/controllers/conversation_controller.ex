defmodule ChatterboxHost.ConversationController do
  use ChatterboxHost.Web, :controller

  def join_conversation(conn, %{"id" => id}) do
    render conn, "join_conversation.html", id: id
  end
end
