defmodule ChatterboxHost.ConversationController do
  use ChatterboxHost.Web, :controller
  alias ChatterboxHost.{Conversation,ConversationView,Tag}
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
    conversation = Repo.get_by!(Conversation, id: conversation_id)
    possible_tags = Repo.all(Tag) |> Enum.map(fn(tag) -> {tag.name, tag.id} end)
    render(conn, "show.html", %{
      id: conversation_id,
      layout: {ConversationView, "layout.html"},
      ended: Conversation.ended?(conversation),
      possible_tags: possible_tags
    })
  end

  def set_tags(conn, %{"conversation_tags" => %{"tag_ids" => tag_ids}, "id" => conversation_id}) do
    conversation = Repo.get_by!(Conversation, id: conversation_id)
    IO.inspect tag_ids
    changeset = Tag.changset_to_update(conversation, tag_ids)
    text conn, "um this is not yet implemented"
  end
end
