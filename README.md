## Passwordless

Example of using Passwordless & JWT tokens in a Phoenix Application

##Running:

1. Ensure Elixir is installed
2. Ensure docker is installed
3. run `docker-compose up -d` to start the database
4. mix ecto.create
5. mix ecto.migrate
6. mix espec

Will need to fill out the following in prod.secrets

config :auth, Auth.Endpoint,
  secret_key_base:  # Use value created with `mix phoenix.gen.secret.`

config :auth,
  mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
  mailgun_key: System.get_env("MAILGUN_API_KEY")

config :guardian, Guardian,
  secret_key: # Use value created with `mix phoenix.gen.secret.`
