defmodule Auth.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string
      add :passwordless_token, :string
      add :token_expiration, :datetime

      timestamps()
    end

    create index(:users, [:email], unique: true)
  end
end
