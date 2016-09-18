defmodule Auth.AuthControllerTest do

  use ESpec, async: false
  import Auth.Factory

  @authority "localhost:#{Application.get_env(:auth, Auth.Endpoint)[:http][:port]}"
  @file_path "/tmp/mailgun.json"

  before do
    Auth.Repo.delete_all(Auth.User)
    File.rm @file_path

    HTTPoison.start
  end

  context "/auth/email" do
    subject do
      if shared.email == nil do
        HTTPoison.post!("#{@authority}/auth/email", {:form, []})
      else
        HTTPoison.post!("#{@authority}/auth/email", {:form, [email: shared.email]})
      end
    end

    context "given a valid email" do
      context "when the user has not previously created an account" do
        before do
          {:shared, email: "foo@example.com"}
        end

        it "it should return success and send an email" do
          expect subject.headers
            |> Enum.find(fn ({x, _}) -> x == "content-type" end)
            |> to(eq {"content-type", "application/json; charset=utf-8"})

          expect subject.status_code |> to(eq 200)
          expect Poison.decode!(subject.body) |> to(eq %{"message" => "a sign in token has been sent to your email."})

          file_contents = Poison.decode! File.read!(@file_path)
          expect file_contents["to"] |> to(eq shared.email)
          expect file_contents["text"] |> to(match ~r/your token is \d{6}\./)
          expect file_contents["subject"] |> to(eq "hello!")
          expect file_contents["from"] |> to(eq "info@example.com")
        end
      end

      context "when the user has previously created an account" do
        before do
          user = insert(:user)
          {:shared, email: user.email}
        end

        it "it should return success and send an email" do
          expect subject.headers
            |> Enum.find(fn ({x, _}) -> x == "content-type" end)
            |> to(eq {"content-type", "application/json; charset=utf-8"})

          expect subject.status_code |> to(eq 200)
          expect Poison.decode!(subject.body) |> to(eq %{"message" => "a sign in token has been sent to your email."})

          file_contents = Poison.decode! File.read!(@file_path)
          expect file_contents["to"] |> to(eq shared.email)
          expect file_contents["text"] |> to(match ~r/your token is \d{6}\./)
          expect file_contents["subject"] |> to(eq "hello!")
          expect file_contents["from"] |> to(eq "info@example.com")
        end
      end
    end

    context "given no email" do
      before do
        {:shared, email: nil}
      end

      it "it should return an params missing error and not send an email" do
        expect subject.headers
          |> Enum.find(fn ({x, _}) -> x == "content-type" end)
          |> to(eq {"content-type", "application/json; charset=utf-8"})

        error = Error.exception(error: "param.missing", param: "email")
        expect subject.status_code |> to(eq error.plug_status)
        expect Poison.decode!(subject.body) |> to(eq %{"errors" => [error.message]})

        {:error, reason} = File.read(@file_path)
        expect reason |> to(eq :enoent)
      end
    end

    context "given an invalid email" do
      before do
        {:shared, email: "value"}
      end

      it "it should return an invalid format error and not send an email" do
        expect subject.headers
          |> Enum.find(fn ({x, _}) -> x == "content-type" end)
          |> to(eq {"content-type", "application/json; charset=utf-8"})

        expect subject.status_code |> to(eq 422)
        expect Poison.decode!(subject.body) |> to(eq %{"errors" => [%{"email" => ["has invalid format"]}]})

        {:error, reason} = File.read(@file_path)
        expect reason |> to(eq :enoent)
      end
    end
  end

  context "/auth/login" do

    subject do
      cond do
        shared.email == nil && shared.token == nil ->
          HTTPoison.post!("#{@authority}/auth/login", {:form, []})
        shared.email == nil ->
          HTTPoison.post!("#{@authority}/auth/login", {:form, [token: shared.token]})
        shared.token == nil ->
          HTTPoison.post!("#{@authority}/auth/login", {:form, [email: shared.email]})
        true ->
          HTTPoison.post!("#{@authority}/auth/login", {:form, [email: shared.email, token: shared.token]})
      end
    end

    context "given no email or token" do
      before do
        {:shared, email: nil, token: nil}
      end

      it "it should return a missing param error" do
        expect subject.headers
          |> Enum.find(fn ({x, _}) -> x == "content-type" end)
          |> to(eq {"content-type", "application/json; charset=utf-8"})

        error = Error.exception(error: "param.missing", param: "email / token")
        expect subject.status_code |> to(eq error.plug_status)
        expect Poison.decode!(subject.body) |> to(eq %{"errors" => [error.message]})
      end
    end

    context "given no email" do
      before do
        {:shared, email: nil, token: "123456"}
      end

      it "it should return a missing param error" do
        expect subject.headers
          |> Enum.find(fn ({x, _}) -> x == "content-type" end)
          |> to(eq {"content-type", "application/json; charset=utf-8"})

        error = Error.exception(error: "param.missing", param: "email / token")
        expect subject.status_code |> to(eq error.plug_status)
        expect Poison.decode!(subject.body) |> to(eq %{"errors" => [error.message]})
      end
    end

    context "given no token" do
      before do
        {:shared, email: "foo@example.com", token: nil}
      end

      it "it should return a missing param error" do
        expect subject.headers
          |> Enum.find(fn ({x, _}) -> x == "content-type" end)
          |> to(eq {"content-type", "application/json; charset=utf-8"})

        error = Error.exception(error: "param.missing", param: "email / token")
        expect subject.status_code |> to(eq error.plug_status)
        expect Poison.decode!(subject.body) |> to(eq %{"errors" => [error.message]})
      end
    end

    context "given an email and invalid token" do
      before do
        {:shared, email: "foo@example.com", token: "123456"}
      end

      it "it should return a missing param error" do
        expect subject.headers
          |> Enum.find(fn ({x, _}) -> x == "content-type" end)
          |> to(eq {"content-type", "application/json; charset=utf-8"})

        error = Error.exception(error: "invalid.login")
        expect subject.status_code |> to(eq error.plug_status)
        expect Poison.decode!(subject.body) |> to(eq %{"errors" => [error.message]})
      end
    end

    context "given an email and expired token" do
      before do
        token_expiration = Timex.shift Timex.now, minutes: -1
        user = insert(:user, token_expiration: token_expiration )
        {:shared, email: user.email, token: user.passwordless_token}
      end

      it "it should return an invalid login error" do
        expect subject.headers
          |> Enum.find(fn ({x, _}) -> x == "content-type" end)
          |> to(eq {"content-type", "application/json; charset=utf-8"})

        error = Error.exception(error: "invalid.login")
        expect subject.status_code |> to(eq error.plug_status)
        expect Poison.decode!(subject.body) |> to(eq %{"errors" => [error.message]})
      end
    end

    context "given an email and valid token from another user" do
      before do
        user1 = insert(:user)
        user2 = insert(:user)
        {:shared, email: user1.email, token: user2.passwordless_token}
      end

      it "it should return an invalid login error" do
        expect subject.headers
          |> Enum.find(fn ({x, _}) -> x == "content-type" end)
          |> to(eq {"content-type", "application/json; charset=utf-8"})

        error = Error.exception(error: "invalid.login")
        expect subject.status_code |> to(eq error.plug_status)
        expect Poison.decode!(subject.body) |> to(eq %{"errors" => [error.message]})
      end
    end

    context "given an email and valid token" do
      before do
        user = insert(:user)
        {:shared, user: user, email: user.email, token: user.passwordless_token}
      end

      it "it returns a 200 with a JWT for the user" do
        expect subject.headers
          |> Enum.find(fn ({x, _}) -> x == "content-type" end)
          |> to(eq {"content-type", "application/json; charset=utf-8"})

        expect subject.status_code |> to(eq 200)

        %{"data" => %{"access_token" => access_token,"token_type" => token_type}} = Poison.decode!(subject.body)
        {:ok, %{"sub" => sub}} = Guardian.decode_and_verify access_token

        expect token_type |> to(eq "Bearer")
        expect sub |> to(eq "User:#{shared.user.id}")
      end
    end
  end
end
