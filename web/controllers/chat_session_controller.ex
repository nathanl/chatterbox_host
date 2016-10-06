defmodule ChatterboxHost.ChatSessionController do
  use ChatterboxHost.Web, :controller
  alias ChatterboxHost.{Endpoint,Repo,Conversation}

  def give_help(conn, %{"conversation_id" => conversation_id}) do
    conversation = Repo.get_by(Conversation, id: conversation_id)
    render_data = case conversation do
      nil -> %{error: "The requested conversation does not exist"}
      %Conversation{} ->
        cs_rep = Chatterbox.Hooks.user_for_session(conn)
        user_id_token = user_id_token(cs_rep)
        conversation_id_token = Phoenix.Token.sign(Endpoint, "conversation_id", conversation_id)
        %{
          user_id_token: user_id_token,
          user_name: cs_rep.name,
          channel_name: "conversation:#{conversation_id}",
          conversation_id_token: conversation_id_token
        }
    end

    render conn, render_data
  end

  def get_help(conn, _params) do
    user = Chatterbox.Hooks.user_for_session(conn)
    
    user_id_token = user_id_token(user)

    conversation_id = new_or_existing_conversation_id(conn)

    conn = conn |> put_session(:getting_help_in_conversation_id, conversation_id)
    conversation_id_token = Phoenix.Token.sign(Endpoint, "conversation_id", conversation_id)

    render conn, user_id_token: user_id_token, user_name: user.name, channel_name: "conversation:#{conversation_id}", conversation_id_token: conversation_id_token
  end

  def close_conversation(conn, %{"conversation_id_token" => conversation_id_token}) do
    closed_conversation = with {:ok, conversation_id} <- Phoenix.Token.verify(
      Endpoint, "conversation_id", conversation_id_token
    ), conversation <- Repo.get_by(Conversation, id: conversation_id),
    %Conversation{} <- conversation do
      {:ok, conversation} = Conversation.end_now(conversation) |> Repo.update
      conversation
    end

    conn = conn |> clear_conversation_from_session(closed_conversation)

    render conn, ended_at: Ecto.DateTime.to_string(closed_conversation.ended_at)
  end

  def clear(conn, _assigns) do
    conn = conn |> put_session(:getting_help_in_conversation_id, nil)

    render conn, %{}
  end

  defp new_or_existing_conversation_id(conn) do
    with convo_id when not is_nil(convo_id) <- get_session(conn, :getting_help_in_conversation_id),
    %Conversation{} <- Repo.get_by(Conversation, id: convo_id) do
      convo_id
    else
      _ ->
        new_conversation = Conversation.changeset(%Conversation{})
        IO.inspect ["new conversation is", new_conversation]
        {:ok, new_conversation} = Repo.insert(new_conversation)
        new_conversation.id
    end 
  end

  defp user_id_token(user) do
    case user.id do
      nil -> nil
      _id  -> Phoenix.Token.sign(Endpoint, "user_id", user.id)
    end
  end

  defp clear_conversation_from_session(conn, conversation) do
    with session_conversation_id <- get_session(conn, :getting_help_in_conversation_id),
    session_conversation_id <- conversation.id do
      conn |> put_session(:getting_help_in_conversation_id, nil)
    else
      _ -> conn
    end
  end

end
