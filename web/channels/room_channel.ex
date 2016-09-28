defmodule ChatterboxHost.RoomChannel do
  use Phoenix.Channel
  alias ChatterboxHost.{Repo,Conversation,Message}
  require Ecto.Query

  def join("conversation:" <> requested_id, %{"conversation_id_token" => conversation_id_token}, socket) do
    {:ok, authorized_id} = Phoenix.Token.verify(
      ChatterboxHost.Endpoint, "conversation_id", conversation_id_token
    )
    [requested_id, authorized_id] = Enum.map([requested_id, authorized_id], &ensure_integer/1)
    
    if requested_id == authorized_id do
      send(self, {:after_join, authorized_id})
      socket = assign(socket, :conversation_id, authorized_id)
      {:ok, socket}
    else
      {:error, "Not authorized to join this conversation"}
    end
  end

  def handle_info({:after_join, conversation_id}, socket) do
    messages_query = Ecto.Query.from m in Message, order_by: m.inserted_at
    conversation = Repo.one(Ecto.Query.from c in Conversation, where: c.id == ^conversation_id, preload: [messages: ^messages_query])
    conversation.messages |> Enum.each(fn (message) ->
      push(socket, "new_msg", %{timestamp: Ecto.DateTime.to_string(message.inserted_at), from: message.sender_name, body: message.content})
    end)

    if Conversation.closed?(conversation) do
      push(socket, "conversation_closed", %{})
    end

    {:noreply, socket}
  end

  # TODO do not accept new messages after the conversation is closed
  def handle_in("new_msg", %{"body" => body, "user_name" => user_name, "user_id_token" => user_id_token}, socket) do
    message = record_message(socket.assigns[:conversation_id], body, user_id_token, user_name)

    broadcast!(socket, "new_msg", %{timestamp: Ecto.DateTime.to_string(message.inserted_at), from: user_name, body: body,  })
    {:noreply, socket}
  end

  def handle_in("conversation_closed", %{"closed_by" => closed_by, "user_id_token" => user_id_token, "closed_at" => closed_at}, socket) do
    body = "[Conversation closed by #{closed_by} at #{closed_at}]"
    sender_name = "System"
    message = record_message(socket.assigns[:conversation_id], body, user_id_token, sender_name)

    broadcast!(socket, "new_msg", %{timestamp: Ecto.DateTime.to_string(message.inserted_at), from: sender_name, body: body})
    broadcast!(socket, "conversation_closed", %{})
    {:noreply, socket}
  end

  defp record_message(conversation_id, content, user_id_token, sender_name) do
    user_id = case Phoenix.Token.verify(ChatterboxHost.Endpoint, "user_id", user_id_token) do
      {:ok, verified_id} -> verified_id
      _ -> nil
    end

    new_message =
      %Message{content: content, conversation_id: conversation_id, sender_name: sender_name, sender_id: user_id}
      |> Message.changeset
      {:ok, message} = Repo.insert(new_message)
      message
  end

  defp ensure_integer(n) when is_integer(n), do: n
  defp ensure_integer(n) when is_binary(n) do
     case Integer.parse(n) do
       {intpart, _nonintpart} -> intpart
       _ -> raise "invalid integer"
     end
  end

end
