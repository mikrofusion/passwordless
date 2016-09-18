defmodule Auth.Factory do
  use ExMachina.Ecto, repo: Auth.Repo
  use Timex

  @token_expiration_in_mins 15

  def user_factory do

    token_expiration = Timex.shift Timex.now, minutes: @token_expiration_in_mins

    %Auth.User{
      email: sequence(:email, &"foo-#{&1}@example.com"),
      passwordless_token: sequence(:passwordless_token, &"#{&1}00000"),
      token_expiration: token_expiration
    }
  end
end
