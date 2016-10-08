defmodule ChatterboxHost.CsPanelChannel do
  use Phoenix.Channel
  alias ChatterboxHost.{Repo,Conversation,Message}
  alias Conversation.{Scopes,Filters}
  require Ecto.Query

  def join("cs_panel", _params, socket) do
    {:ok, socket}
  end

  def send_updated_panel do
    {:safe, iodata} = Phoenix.View.render(ChatterboxHost.ConversationView, "index.html",conversations: collection_for_cs_panel)
    html = :erlang.iolist_to_binary(iodata)
  ChatterboxHost.Endpoint.broadcast("cs_panel", "panel_update", %{body: html})
  end

  def collection_for_cs_panel do
    query =
      Conversation
      |> Scopes.id_and_message_info

    conversations = [
      {"Unanswered", (query |> Scopes.not_ended |> Scopes.sequential |> Repo.all |> Filters.unanswered)},
      {"Ongoing", (query |> Scopes.not_ended |> Scopes.sequential |> Repo.all |> Filters.ongoing)},
      {"Ended", (query |> Scopes.ended |> Scopes.reverse_sequential |> Ecto.Query.limit(3) |> Repo.all)},
    ]
  end

end
