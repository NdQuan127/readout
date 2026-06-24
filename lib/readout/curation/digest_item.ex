defmodule Readout.Curation.DigestItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "digest_items" do
    belongs_to :digest, Readout.Curation.Digest
    belongs_to :summary, Readout.Analysis.ArticleSummary

    timestamps(type: :utc_datetime)
  end

  def changeset(digest_item, attrs) do
    digest_item
    |> cast(attrs, [:digest_id, :summary_id])
    |> validate_required([:digest_id, :summary_id])
    |> unique_constraint([:digest_id, :summary_id])
  end
end
