# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :auth,
  ecto_repos: [Auth.Repo]

# Configures the endpoint
config :auth, Auth.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "some secret",
  render_errors: [view: Auth.ErrorView, accepts: ~w(json), default_format: "json"],
  pubsub: [name: Auth.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :auth,
  mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
  mailgun_key: System.get_env("MAILGUN_API_KEY")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Add mix-test.watch
if Mix.env == :dev do
  config :mix_test_watch,
    tasks: [
      "espec",
      "credo --strict"
    ]
end

config :guardian, Guardian,
  allowed_algos: ["HS512"],      # optional
  verify_module: Guardian.JWT,   # optional
  issuer: "Auth",
  ttl: { 30, :days },
  verify_issuer: true,           # optional
  serializer: Auth.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
