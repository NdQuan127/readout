defmodule Readout.Analysis.ArticleSummary do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "article_summaries" do
    field :summary_text, :string
    field :tags, {:array, :string}, default: []

    belongs_to :article, Readout.Ingestion.Article

    timestamps(type: :utc_datetime)
  end

  def changeset(summary, attrs) do
    summary
    |> cast(attrs, [:article_id, :summary_text, :tags])
    |> validate_required([:article_id, :summary_text])
    |> unique_constraint(:article_id)
  end
end
