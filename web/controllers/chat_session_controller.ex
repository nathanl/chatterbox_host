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

  def get_help(conn, %{"conversation_id_token" => conversation_id_token}) do
    user = Chatterbox.Hooks.user_for_session(conn)
    
    user_id_token = user_id_token(user)

    conversation_id = new_or_existing_conversation_id(conversation_id_token)

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

    render conn, ended_at: Ecto.DateTime.to_string(closed_conversation.ended_at)
  end

  defp new_or_existing_conversation_id(convo_id_token) do
    with {:ok, convo_id} <- Phoenix.Token.verify(
      Endpoint, "conversation_id", convo_id_token
    ), 
    %Conversation{} <- Repo.get_by(Conversation, id: convo_id) do
      convo_id
    else
      _ ->
        new_conversation = Conversation.changeset(%Conversation{})
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
end
