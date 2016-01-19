ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Clio.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Clio.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Clio.Repo)

