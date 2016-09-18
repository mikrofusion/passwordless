defmodule Auth.AuthController do
  @moduledoc """
  """

  use Auth.Web, :controller
  alias Auth.Passwordless

  @doc ~S"""
  """
  def email(conn, params) do
    Passwordless.email(params)
    render(conn, "email.json")
  end

  @doc ~S"""
  """
  def login(conn, params) do
    { :ok, jwt, claims } = Passwordless.login(params)

    conn
    |> render("token.json", %{data: %{token_type: "Bearer", access_token: jwt}})
  end

end
