defmodule Readout.Ingestion.UserSource do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "user_sources" do
    belongs_to :user, Readout.Accounts.User
    belongs_to :source, Readout.Ingestion.Source

    timestamps(type: :utc_datetime)
  end

  def changeset(user_source, attrs) do
    user_source
    |> cast(attrs, [:user_id, :source_id])
    |> validate_required([:user_id, :source_id])
    |> unique_constraint([:user_id, :source_id])
  end
end
