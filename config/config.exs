# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :chatterbox_host,
  ecto_repos: [ChatterboxHost.Repo]

# Configures the endpoint
config :chatterbox_host, ChatterboxHost.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vyW3zTaLvNLlM5znUmlvbZEFchmaKuLMsz9sd/x/7pXkK8/dP52UquZQ3deWeECT",
  render_errors: [view: ChatterboxHost.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ChatterboxHost.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
