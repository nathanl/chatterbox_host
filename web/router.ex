defmodule ChatterboxHost.Router do
  use ChatterboxHost.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatterboxHost do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/registrations", RegistrationController, only: [:new, :create]
    get    "/login",  SessionController, :new
    post   "/login",  SessionController, :create
    delete "/logout", SessionController, :delete
    get "/conversations/:id", ConversationController, :show
    get "/conversations",    ConversationController, :index
    post "/set_tags/:id",    ConversationController, :set_tags
  end

  # Other scopes may use custom stacks.
  scope "/api", ChatterboxHost do
    pipe_through :api
    get  "/get_help",                        ChatSessionController, :get_help
    get  "/give_help/:conversation_id",      ChatSessionController, :give_help
    put  "/close_conversation/:conversation_id_token", ChatSessionController, :close_conversation
  end
end
