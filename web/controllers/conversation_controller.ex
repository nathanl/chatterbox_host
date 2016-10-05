defmodule ChatterboxHost.ConversationController do
  use ChatterboxHost.Web, :controller
  alias ChatterboxHost.{Conversation,ConversationView,Tag,ConversationTag}
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
    conversation = conversation_with_tags(conversation_id)
    possible_tags = Repo.all(Tag) |> Enum.map(fn(tag) -> {tag.name, tag.id} end)
    render(conn, "show.html", %{
      id: conversation_id,
      layout: {ConversationView, "layout.html"},
      ended: Conversation.ended?(conversation),
      possible_tags: possible_tags,
      current_tag_ids: (conversation.conversation_tags |> Enum.map(&(&1.tag_id))),
    })
  end

  def set_tags(conn, %{"tag_ids" => tag_ids, "id" => conversation_id}) do
    conversation = conversation_with_tags(conversation_id)
    existing_taggings = conversation.conversation_tags
    {:ok, to_delete, to_insert} = ConversationTag.updates_for(
      existing_taggings, conversation_id, checked_values_from(tag_ids)
    )

    to_insert = to_insert |> (Enum.map(fn (ct) ->
      ConversationTag.changeset(
        %ConversationTag{},
        %{
          tag_id: ct.tag_id,
          conversation_id: ct.conversation_id,
        }
        )
    end))

    multi = to_delete |> Enum.reduce(Ecto.Multi.new, fn (record, multi_acc) ->
      Ecto.Multi.delete(multi_acc, "delete_#{record.id}", record)
    end)
    multi = to_insert |> Enum.reduce(multi, fn (changeset, multi_acc) ->
      # TODO make this less horrible and hacky!
      Ecto.Multi.insert(multi_acc, "insert_#{:rand.uniform(1_000)}", changeset)
    end)
    Repo.transaction(multi)

    # TODO should not need to use 'external' here; fix local_referer, maybe PR to framework?
    redirect conn, external: referer(conn)
  end

  defp conversation_with_tags(conversation_id) do
    query = from c in Conversation, where: c.id == ^conversation_id, preload: :conversation_tags
    ChatterboxHost.Repo.one!(query)
  end

  defp checked_values_from(checkbox_params) do
    checkbox_params |>
    Enum.reduce([], fn ({k, v}, acc) ->
    if v == "true", do: [k | acc], else: acc
    end)
  end

  def referer(conn) do
    case List.keyfind(conn.req_headers, "referer", 0) do
      {"referer", referer} -> referer
      nil -> raise "no referer"
    end
  end

  # def local_referer(conn) do
  #   url = conn |> referer
  #   start = "#{conn.schema}//#{conn.host}:#{conn.port}/"
  #   start <> local_path = url
  #   # "#{start}/#{local_path}" = url
  # end
end
