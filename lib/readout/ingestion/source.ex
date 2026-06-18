defmodule Readout.Ingestion.Source do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "sources" do
    field :canonical_url, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(source, attrs) do
    source
    |> cast(attrs, [:canonical_url, :name])
    |> validate_required([:canonical_url, :name])
    |> unique_constraint(:canonical_url)
  end
end
