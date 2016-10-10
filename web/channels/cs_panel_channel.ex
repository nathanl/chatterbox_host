defmodule Consult.CsPanelChannel do
  use Phoenix.Channel
  alias ChatterboxHost.{Repo,Conversation}
  alias Conversation.{Scopes,Filters}
  require Ecto.Query
  @closed_conversation_count 10 # TODO make configurable

  def join("cs_panel", _params, socket) do
    {:ok, socket}
  end

  def send_updated_panel do
    {:safe, html_iodata} = Phoenix.View.render(
      ChatterboxHost.ConversationView, "index.html",conversations: collection_for_cs_panel
    )
    html_string = :erlang.iolist_to_binary(html_iodata)
    ChatterboxHost.Endpoint.broadcast(
      "cs_panel", "panel_update", %{main_contents: html_string}
    )
  end

  def collection_for_cs_panel do
    query =
      Conversation
      |> Scopes.id_and_message_info

    conversations = [
      {"Unanswered", (query |> Scopes.not_ended |> Scopes.sequential |> Repo.all |> Filters.unanswered)},
      {"Ongoing", (query |> Scopes.not_ended |> Scopes.sequential |> Repo.all |> Filters.ongoing)},
      {"Ended", (query |> Scopes.ended |> Scopes.reverse_sequential |> Ecto.Query.limit(@closed_conversation_count) |> Repo.all)},
    ]
  end

end
