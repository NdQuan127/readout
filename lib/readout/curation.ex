defmodule Readout.Curation do
  import Ecto.Query

  alias Readout.Accounts.Scope
  alias Readout.Analysis.ArticleSummary
  alias Readout.Curation.{Digest, DigestItem}
  alias Readout.Ingestion.{Article, UserSource}
  alias Readout.Repo

  def generate_digest(%Scope{} = scope, %Date{} = date) do
    if date == Date.utc_today() do
      digest = upsert_digest(scope, date)
      summary_ids = eligible_summary_ids(scope, date)
      insert_missing_items(digest, summary_ids)

      {:ok, get_digest(scope, date)}
    else
      {:ok, nil}
    end
  end

  def get_today_digest(%Scope{} = scope) do
    get_digest(scope, Date.utc_today())
  end

  defp upsert_digest(%Scope{user: %{id: user_id}}, date) do
    attrs = %{user_id: user_id, date: date}

    %Digest{}
    |> Digest.changeset(attrs)
    |> Repo.insert!(
      on_conflict: [set: [updated_at: now()]],
      conflict_target: [:user_id, :date],
      returning: true
    )
  end

  defp eligible_summary_ids(%Scope{user: %{id: user_id}}, date) do
    {start_at, end_at} = utc_bounds(date)

    from(summary in ArticleSummary,
      join: article in Article,
      on: article.id == summary.article_id,
      join: user_source in UserSource,
      on: user_source.source_id == article.source_id,
      where: user_source.user_id == ^user_id,
      where: summary.inserted_at >= ^start_at and summary.inserted_at < ^end_at,
      select: summary.id
    )
    |> Repo.all()
  end

  defp insert_missing_items(_digest, []), do: :ok

  defp insert_missing_items(%Digest{id: digest_id}, summary_ids) do
    timestamp = now()

    items =
      Enum.map(summary_ids, fn summary_id ->
        %{
          id: Ecto.UUID.generate(),
          digest_id: digest_id,
          summary_id: summary_id,
          inserted_at: timestamp,
          updated_at: timestamp
        }
      end)

    Repo.insert_all(DigestItem, items,
      on_conflict: :nothing,
      conflict_target: [:digest_id, :summary_id]
    )

    :ok
  end

  defp get_digest(%Scope{user: %{id: user_id}}, date) do
    item_query =
      from(item in DigestItem,
        join: summary in assoc(item, :summary),
        join: article in assoc(summary, :article),
        join: source in assoc(article, :source),
        order_by: [desc: summary.inserted_at, desc: article.published_at],
        preload: [summary: {summary, article: {article, source: source}}]
      )

    from(digest in Digest,
      where: digest.user_id == ^user_id and digest.date == ^date,
      preload: [items: ^item_query]
    )
    |> Repo.one()
  end

  defp utc_bounds(date) do
    start_at = DateTime.new!(date, ~T[00:00:00], "Etc/UTC") |> DateTime.truncate(:second)
    end_at = DateTime.add(start_at, 1, :day)
    {start_at, end_at}
  end

  defp now, do: DateTime.utc_now() |> DateTime.truncate(:second)
end
