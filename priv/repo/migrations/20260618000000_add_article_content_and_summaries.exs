defmodule Readout.Repo.Migrations.AddArticleContentAndSummaries do
  use Ecto.Migration

  def change do
    create table(:article_contents, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :article_id, references(:articles, type: :binary_id, on_delete: :delete_all),
        null: false

      add :text, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:article_contents, [:article_id])

    create table(:article_summaries, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :article_id, references(:articles, type: :binary_id, on_delete: :delete_all),
        null: false

      add :summary_text, :text, null: false
      add :tags, {:array, :text}, null: false, default: []

      timestamps(type: :utc_datetime)
    end

    create unique_index(:article_summaries, [:article_id])

    alter table(:articles) do
      remove :raw_content, :text
    end
  end
end
