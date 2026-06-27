defmodule ReadoutWeb.DemoLive do
  use ReadoutWeb, :live_view

  alias Readout.Ingestion

  @impl true
  def mount(_params, _session, socket) do
    current_scope = socket.assigns.current_scope
    sources = Ingestion.list_sources(current_scope)

    if connected?(socket) do
      Enum.each(sources, &subscribe_to_source/1)
    end

    {:ok,
     socket
     |> assign(:sources, sources)
     |> assign(:url, "")
     |> assign(:error, nil)
     |> assign(:pending_article_ids, MapSet.new())
     |> stream(:articles, Ingestion.list_articles(current_scope))}
  end

  @impl true
  def handle_event("subscribe", %{"source" => %{"url" => url}}, socket) do
    case Ingestion.subscribe_source(socket.assigns.current_scope, %{url: url}) do
      {:ok, source} ->
        subscribe_to_source(source)

        {:noreply,
         socket
         |> assign(:sources, Ingestion.list_sources(socket.assigns.current_scope))
         |> assign(:url, "")
         |> assign(:error, nil)}

      {:error, reason} ->
        {:noreply, assign(socket, url: url, error: error_message(reason))}
    end
  end

  @impl true
  def handle_event("summarize", %{"id" => article_id}, socket) do
    case Ingestion.enqueue_article_scrape(socket.assigns.current_scope, article_id) do
      {:ok, _job} ->
        socket =
          socket
          |> update(:pending_article_ids, fn article_ids ->
            MapSet.put(article_ids, article_id)
          end)
          |> refresh_article(article_id)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:articles_fetched, source_id}, socket) do
    socket =
      socket.assigns.current_scope
      |> Ingestion.list_articles(source_id)
      |> Enum.reverse()
      |> Enum.reduce(socket, &stream_insert(&2, :articles, &1, at: 0))

    {:noreply, socket}
  end

  @impl true
  def handle_info({:article_scraped, article_id}, socket) do
    {:noreply, refresh_article(socket, article_id)}
  end

  @impl true
  def handle_info({:article_summarized, article_id}, socket) do
    socket =
      socket
      |> update(:pending_article_ids, &MapSet.delete(&1, article_id))
      |> refresh_article(article_id)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="grid gap-8 lg:grid-cols-[18rem_1fr]">
        <section>
          <h1 class="text-2xl font-semibold">Readout</h1>
          <p class="mt-1 text-sm text-m3-on-surface-variant">{@current_scope.user.email}</p>

          <form phx-submit="subscribe" class="mt-6 space-y-2">
            <label for="source-url" class="block text-sm font-medium">RSS or Atom URL</label>
            <input
              id="source-url"
              name="source[url]"
              type="url"
              value={@url}
              class="m3-field"
              placeholder="https://example.com/feed.xml"
            />
            <p :if={@error} id="source-url-error" class="text-sm text-m3-error">{@error}</p>
            <button class="m3-btn m3-btn-filled m3-state m3-ripple w-full" type="submit">
              Subscribe
            </button>
          </form>

          <h2 class="mt-8 font-semibold">Sources</h2>
          <ul id="sources" class="mt-3 space-y-2">
            <li :for={source <- @sources} id={"source-#{source.id}"}>{source.name}</li>
          </ul>
        </section>

        <section>
          <h2 class="text-xl font-semibold">Latest articles</h2>
          <div id="articles" phx-update="stream" class="mt-4 space-y-4">
            <article :for={{dom_id, article} <- @streams.articles} id={dom_id}>
              <a href={article.canonical_url} class="font-medium hover:underline">{article.title}</a>
              <div class="mt-2 flex items-center gap-2">
                <button
                  type="button"
                  phx-click="summarize"
                  phx-value-id={article.id}
                  disabled={MapSet.member?(@pending_article_ids, article.id)}
                  class="m3-btn m3-btn-outlined m3-state m3-ripple"
                >
                  <%= if MapSet.member?(@pending_article_ids, article.id) do %>
                    Đang xử lý
                  <% else %>
                    Tóm tắt
                  <% end %>
                </button>
                <span :if={article.content && !article.summary} class="m3-chip m3-chip-neutral">
                  Đã cào {String.length(article.content.text)} ký tự
                </span>
              </div>
              <div :if={article.summary} class="mt-3 space-y-2">
                <p class="text-sm text-m3-on-surface-variant">{article.summary.summary_text}</p>
                <div :if={article.summary.tags != []} class="flex flex-wrap gap-2">
                  <span :for={tag <- article.summary.tags} class="m3-chip">{tag}</span>
                </div>
              </div>
            </article>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  defp subscribe_to_source(source) do
    Phoenix.PubSub.subscribe(Readout.PubSub, "source:#{source.id}:fetched")
    Phoenix.PubSub.subscribe(Readout.PubSub, "source:#{source.id}:scraped")
    Phoenix.PubSub.subscribe(Readout.PubSub, "source:#{source.id}:summarized")
  end

  defp refresh_article(socket, article_id) do
    case Ingestion.get_article(socket.assigns.current_scope, article_id) do
      nil -> socket
      article -> stream_insert(socket, :articles, article)
    end
  end

  defp error_message(:invalid_source_url), do: "Enter a valid HTTP or HTTPS URL."
  defp error_message({:feed_unreachable, status}), do: "Feed returned HTTP #{status}."
  defp error_message(:feed_unreachable), do: "Feed could not be reached."
  defp error_message(:invalid_rss_format), do: "URL is not a valid RSS or Atom feed."
  defp error_message(_reason), do: "Source could not be subscribed."
end
