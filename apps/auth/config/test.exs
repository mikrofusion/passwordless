use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :auth, Auth.Endpoint,
  http: [port: 4000],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :auth, Auth.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "auth_test",
  hostname: "localhost",
  port: "65432",
  pool: Ecto.Adapters.SQL.Sandbox

config :guardian, Guardian,
  secret_key: "CqqxNZwjcHy6UjdHzYbJ1vQ27/5SqhDeG/MU0vbgsaqp7fw4gt63DojGpDY2Ik5K" # NOTE: use different value in production.  Created with `mix phoenix.gen.secret.`
