defmodule ChatterboxHost.ConversationController do
  use ChatterboxHost.Web, :controller
  alias ChatterboxHost.{Conversation,ConversationView}
  alias Conversation.{Scopes,Filters}

  def index(conn, _assigns) do
    query =
      Conversation
      |> Scopes.id_and_message_info

    conversations = [
      {"Unanswered", (query |> Scopes.not_ended |> Scopes.sequential |> Repo.all |> Filters.unanswered)},
      {"Ongoing", (query |> Scopes.not_ended |> Scopes.sequential |> Repo.all |> Filters.ongoing)},
      {"Ended", (query |> Scopes.ended |> Scopes.reverse_sequential |> limit(3) |> Repo.all)},
    ]

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
