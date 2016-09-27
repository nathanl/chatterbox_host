defmodule ChatterboxHost.ChatSessionController do
  use ChatterboxHost.Web, :controller
  alias ChatterboxHost.Repo
  alias ChatterboxHost.User
  alias ChatterboxHost.Conversation

  def index(conn, _assigns) do
    conversations = Repo.all(Conversation |> Conversation.ongoing)
    render conn, %{conversations: conversations}
  end

  def give_help(conn, %{"conversation_id" => conversation_id}) do
    conn = conn |> fetch_session
    conversation = Repo.get_by(ChatterboxHost.Conversation, id: conversation_id)
    render_data = case conversation do
      nil -> %{error: "The requested conversation does not exist"}
      %Conversation{} ->
        user = user_for_session(conn)
        case user_may_join_conversation?(user, conversation) do
          :ok -> 
            user_id_token = user_id_token(user)
            conversation_id_token = Phoenix.Token.sign(ChatterboxHost.Endpoint, "conversation_id", conversation_id)
            %{
              user_id_token: user_id_token,
              user_name: user.name,
              channel_name: "conversation:#{conversation_id}",
              conversation_id_token: conversation_id_token
            }
          {:error, message} ->
            %{error: message}
        end
    end

    render conn, render_data
  end

  def get_help(conn, _params) do
    conn = conn |> fetch_session
    user = user_for_session(conn)
    
    user_id_token = user_id_token(user)

    conversation_id = new_or_existing_conversation_id(conn)

    conn = conn |> put_session(:getting_help_in_conversation_id, conversation_id)
    conversation_id_token = Phoenix.Token.sign(ChatterboxHost.Endpoint, "conversation_id", conversation_id)

    render conn, user_id_token: user_id_token, user_name: user.name, channel_name: "conversation:#{conversation_id}", conversation_id_token: conversation_id_token
  end

  def close_conversation(conn, %{"conversation_id_token" => conversation_id_token}) do
    conn = conn |> fetch_session

    closed_conversation = with {:ok, conversation_id} <- Phoenix.Token.verify(
      ChatterboxHost.Endpoint, "conversation_id", conversation_id_token
    ), conversation <- Repo.get_by(Conversation, id: conversation_id),
    %Conversation{} <- conversation do
      {:ok, conversation} = Conversation.close(conversation) |> Repo.update
      conversation
    end

    conn = conn |> clear_conversation_from_session(closed_conversation)

    render conn, closed_at: Ecto.DateTime.to_string(closed_conversation.closed_at)
  end

  defp new_or_existing_conversation_id(conn) do
    with convo_id when not is_nil(convo_id) <- get_session(conn, :getting_help_in_conversation_id),
    %Conversation{} <- Repo.get_by(Conversation, id: convo_id) do
      convo_id
    else
      _ ->
        new_conversation = Conversation.changeset(%Conversation{})
        IO.inspect ["new conversation is", new_conversation]
        {:ok, new_conversation} = ChatterboxHost.Repo.insert(new_conversation)
        new_conversation.id
    end 
  end

  defp user_id_token(user) do
    case user.id do
      nil -> nil
      _id  -> Phoenix.Token.sign(ChatterboxHost.Endpoint, "user_id", user.id)
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

  # TODO move this to a module; app is responsible for it
  defp user_may_join_conversation?(user, _conversation) do
    case user do
      %User{cs_rep: true} -> :ok
      %User{}             -> {:error, "You are not allowed to join this conversation"}
      _                   -> {:error, "Anonymous users may not join existing conversations"}
    end
  end

  # TODO move this to a module; app is responsible for it
  # could be a null user
  defp user_for_session(conn) do
    user = with user_id when is_integer(user_id) <- (conn |> get_session(:user_id)),
    do: Repo.get_by(User, id: user_id)

    case user do
      %User{} -> user
      _       -> %{id: nil, name: "Anonymous"}
    end
  end

end
