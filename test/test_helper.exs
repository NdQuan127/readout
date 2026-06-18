ExUnit.start()

if Process.whereis(Readout.Repo) do
  Ecto.Adapters.SQL.Sandbox.mode(Readout.Repo, :manual)
end
