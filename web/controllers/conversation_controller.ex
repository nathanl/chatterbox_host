defmodule ChatterboxHost.ConversationController do
  use ChatterboxHost.Web, :controller
  alias ChatterboxHost.{Conversation,ConversationView}

  def index(conn, _assigns) do
    conversations = Repo.all(Conversation |> Conversation.ongoing)
    render conn, conversations: conversations, layout: {ConversationView, "layout.html"}
  end

  def show(conn, %{"id" => id}) do
    render conn, "show.html", id: id, layout: {ConversationView, "layout.html"}
  end
end
