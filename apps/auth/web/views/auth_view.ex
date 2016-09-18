defmodule Auth.AuthView do
  @moduledoc false

  def render("email.json", conn) do
    %{message: "a sign in token has been sent to your email."}
  end

  def render("token.json", %{data: data}) do
    %{data: data}
  end
end
