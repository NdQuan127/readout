defmodule Readout.Ingestion.Article do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "articles" do
    field :canonical_url, :string
    field :title, :string
    field :published_at, :utc_datetime

    belongs_to :source, Readout.Ingestion.Source
    has_one :content, Readout.Ingestion.ArticleContent
    has_one :summary, Readout.Analysis.ArticleSummary

    timestamps(type: :utc_datetime)
  end
end
