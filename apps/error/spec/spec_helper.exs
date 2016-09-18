ExUnit.start

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
