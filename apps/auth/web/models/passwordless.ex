defmodule Auth.Passwordless do
  @moduledoc """
  """

  alias Auth.User
  use Timex

  @token_expiration_in_mins 15

  @doc """
  """
  def email(%{"email" => email}) do
    token = "#{Enum.random(111111..999999)}"
    token_expiration = Timex.shift Timex.now, minutes: @token_expiration_in_mins

    result =
      case Auth.Repo.get_by(User, email: email) do
        nil  -> %User{}
        user -> user
      end
      |> User.changeset(%{email: email,
                          passwordless_token: token,
                          token_expiration: token_expiration})
      |> Auth.Repo.insert_or_update

    case result do
      {:ok, _} ->
        Auth.Mailer.send_welcome_text_email(%{email: email, token: token})
        {:ok}
      {:error, changeset} ->
        raise Error, error: "changeset.error", param: changeset
    end
  end

  @doc """
  """
  def email(_params) do
    raise Error, error: "param.missing", param: "email"
  end

  @doc """
  """
  def login(%{"email" => email, "token" => token}) do
    now = Timex.now
    case Auth.Repo.get_by(User, email: email, passwordless_token: token) do
      nil ->
        raise Error, error: "invalid.login"
      %User{token_expiration: token_expiration} = user ->
        if Timex.before?(token_expiration, now) do
          raise Error, error: "invalid.login"
        end

        { :ok, jwt, full_claims } = Guardian.encode_and_sign(user, :token)
    end
  end

  @doc """
  """
  def login(_params) do
    raise Error, error: "param.missing", param: "email / token"
  end
end
