defmodule ChatterboxHost.ChatSessionView do
  use ChatterboxHost.Web, :view

  def render(_something_dot_json, %{error: error}) do
    %{error: error}
  end

  def render(_something_dot_json, %{closed_at: closed_at}) do
    %{closed_at: closed_at}
  end

  def render(_something_dot_json, %{channel_name: conversation, user_name: user_name, user_id_token: user_id_token, conversation_id_token: conversation_id_token}) do
    %{channel_name: conversation, user_name: user_name, user_id_token: user_id_token, conversation_id_token: conversation_id_token}
  end

end
