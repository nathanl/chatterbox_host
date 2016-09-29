defmodule ChatterboxHost.ConversationController do
  use ChatterboxHost.Web, :controller
  alias ChatterboxHost.{Conversation,ConversationView}

  def index(conn, _assigns) do
    conversations = Repo.all(Conversation |> Conversation.ongoing |> Conversation.by_timestamp)
    render conn, conversations: conversations, layout: {ConversationView, "layout.html"}
  end

  def show(conn, %{"id" => conversation_id}) do
    conversation = Repo.get_by(Conversation, id: conversation_id)
    render(conn, "show.html", %{
      id: conversation_id,
      layout: {ConversationView, "layout.html"},
      ended: Conversation.ended?(conversation),
    })
  end
end
