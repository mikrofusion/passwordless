ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Auth.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Auth.Repo --quiet)

{:ok, _} = Application.ensure_all_started(:ex_machina)

Code.require_file("spec/factories/factory.exs")

ESpec.configure fn(config) ->

  config.before fn ->
    :ok
  end

  config.finally fn(_shared) ->
    :ok
  end
end
