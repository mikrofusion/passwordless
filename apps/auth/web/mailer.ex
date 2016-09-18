defmodule Auth.Mailer do
  @config domain: Application.get_env(:auth, :mailgun_domain),
          key: Application.get_env(:auth, :mailgun_key),
          mode: :test,
          test_file_path: "/tmp/mailgun.json"

  use Mailgun.Client, @config

  @from "info@example.com"

  def send_welcome_text_email(user) do
    send_email to: user.email,
               from: @from,
               subject: "hello!",
               text: "your token is #{user.token}."
  end

end
