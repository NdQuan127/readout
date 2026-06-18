defmodule Readout.Repo.Migrations.CreateIngestionTables do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])

    create table(:sources, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :canonical_url, :text, null: false
      add :name, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sources, [:canonical_url])

    create table(:user_sources, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :source_id, references(:sources, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_sources, [:user_id, :source_id])

    create table(:articles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :source_id, references(:sources, type: :binary_id, on_delete: :delete_all), null: false
      add :canonical_url, :text, null: false
      add :title, :text, null: false
      add :published_at, :text
      add :raw_content, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:articles, [:source_id, :canonical_url])
  end
end
