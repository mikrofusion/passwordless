defmodule Auth.User do
  use Auth.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  #use Timex.Ecto.Timestamps

  schema "users" do
    field :email, :string
    field :passwordless_token, :string
    field :token_expiration, Timex.Ecto.DateTime

    timestamps()
  end

  @required_fields ~w(email)
  @optional_fields ~w(passwordless_token token_expiration)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/.*@.*\..*/)
    |> validate_required([:email])
  end
end
