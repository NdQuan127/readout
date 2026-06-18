defmodule Readout.Repo do
  use Ecto.Repo,
    otp_app: :readout,
    adapter: Ecto.Adapters.Postgres
end
