defmodule Consult.ChatSessionView do
  use ChatterboxHost.Web, :view

  def render(_something_dot_json, %{error: error}) do
    %{error: error}
  end

  def render(_something_dot_json, %{ended_at: ended_at}) do
    %{ended_at: ended_at}
  end

  def render(_something_dot_json, %{channel_name: conversation, user_name: user_name, user_id_token: user_id_token, conversation_id_token: conversation_id_token}) do
    %{channel_name: conversation, user_name: user_name, user_id_token: user_id_token, conversation_id_token: conversation_id_token}
  end

  def render("clear.json", %{}) do
    %{ok: :ok}
  end

end
