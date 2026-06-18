defmodule Readout.Repo.Migrations.ChangeArticlePublishedAtToUtcDatetime do
  use Ecto.Migration

  def up do
    execute("""
    ALTER TABLE articles
    ALTER COLUMN published_at TYPE timestamp(0) without time zone
    USING CASE
      WHEN published_at IS NULL THEN NULL
      WHEN published_at ~ '^\\d{4}-\\d{2}-\\d{2}T' THEN
        published_at::timestamptz AT TIME ZONE 'UTC'
      WHEN published_at ~ '^[A-Za-z]{3},' THEN
        to_timestamp(published_at, 'Dy, DD Mon YYYY HH24:MI:SS GMT') AT TIME ZONE 'UTC'
      ELSE NULL
    END
    """)
  end

  def down do
    alter table(:articles) do
      modify :published_at, :text, from: :utc_datetime
    end
  end
end
