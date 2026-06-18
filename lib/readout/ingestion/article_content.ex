defmodule Readout.Ingestion.ArticleContent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "article_contents" do
    field :text, :string

    belongs_to :article, Readout.Ingestion.Article

    timestamps(type: :utc_datetime)
  end

  def changeset(content, attrs) do
    content
    |> cast(attrs, [:article_id, :text])
    |> validate_required([:article_id, :text])
    |> unique_constraint(:article_id)
  end
end
