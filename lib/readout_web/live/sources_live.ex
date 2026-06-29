defmodule ReadoutWeb.SourcesLive do
  use ReadoutWeb, :live_view

  alias Readout.Ingestion

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form_error, nil)
      |> assign(:show_add, false)
      |> assign(:selected, nil)
      |> assign(:recent_articles, [])
      |> assign(:latest_at, nil)
      |> assign_form()
      |> assign_sources()

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    case Enum.find(socket.assigns.sources, &(&1.id == id)) do
      nil -> {:noreply, push_patch(socket, to: ~p"/sources")}
      entry -> {:noreply, select_source(socket, entry)}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign(:selected, nil)
     |> assign(:recent_articles, [])
     |> assign(:latest_at, nil)}
  end

  @impl true
  def handle_event("show_add", _params, socket) do
    {:noreply,
     socket
     |> assign(:form_error, nil)
     |> assign(:show_add, true)
     |> assign(:selected, nil)
     |> assign_form()
     |> push_patch(to: ~p"/sources")}
  end

  @impl true
  def handle_event("close_detail", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_add, false)
     |> assign(:selected, nil)
     |> push_patch(to: ~p"/sources")}
  end

  @impl true
  def handle_event("add_source", %{"source" => source_params}, socket) do
    case Ingestion.subscribe_source(socket.assigns.current_scope, source_params) do
      {:ok, _source} ->
        {:noreply,
         socket
         |> put_flash(:info, "Source added. Fetching articles now.")
         |> assign(:form_error, nil)
         |> assign(:show_add, false)
         |> assign_form()
         |> assign_sources()}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:form_error, error_message(reason))
         |> assign(:show_add, true)
         |> assign_form(source_params["url"])}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.product_shell flash={@flash} current_scope={@current_scope} active_product={:sources}>
      <section
        class="sources"
        data-detail-open={to_string(@selected != nil or @show_add)}
        aria-label="Sources"
      >
        <div class="sources-list-pane flex flex-col gap-4">
          <header class="flex items-center justify-between gap-3">
            <div>
              <p class="text-sm font-medium text-m3-on-surface-variant">Sources</p>
              <h1 class="text-2xl font-semibold">Manage sources</h1>
            </div>
            <button
              :if={@source_count > 0}
              id="show-add-source"
              type="button"
              phx-click="show_add"
              class="m3-btn m3-btn-tonal m3-state m3-ripple shrink-0"
            >
              <span class="msym text-xl" aria-hidden="true">add</span> Add source
            </button>
          </header>

          <ul id="source-list" class="flex flex-col gap-2" role="list">
            <li
              :for={{source, i} <- Enum.with_index(@sources)}
              id={"source-#{source.id}"}
              style={"animation-delay:#{i * 40}ms"}
              aria-current={to_string(selected?(@selected, source))}
            >
              <.link
                patch={~p"/sources/#{source.id}"}
                class={[
                  "m3-card m3-state m3-ripple block p-4 transition-transform duration-200",
                  if(selected?(@selected, source),
                    do: "bg-m3-secondary-container text-m3-on-secondary-container",
                    else:
                      "bg-m3-surface-container-high shadow-[0_1px_2px_rgb(0_0_0/0.04)] hover:-translate-y-0.5"
                  )
                ]}
              >
                <div class="flex items-center gap-3">
                  <span
                    class="msym grid size-9 shrink-0 place-items-center rounded-full bg-m3-primary-container text-lg text-m3-on-primary-container"
                    aria-hidden="true"
                  >
                    rss_feed
                  </span>
                  <div class="min-w-0 flex-1">
                    <p data-role="source-name" class="truncate font-semibold leading-snug">
                      {source.name}
                    </p>
                    <p class="truncate text-xs text-m3-on-surface-variant">
                      {host(source.canonical_url)} · {pluralize(source.article_count, "Article")}
                    </p>
                  </div>
                  <span class="m3-chip shrink-0">{source.status}</span>
                </div>
              </.link>
            </li>
          </ul>
        </div>

        <div
          id="source-detail-pane"
          class={["sources-detail", (@selected || @show_add) && "detail-open"]}
          aria-live="polite"
        >
          <button
            :if={@selected || @show_add}
            type="button"
            phx-click="close_detail"
            class="m3-btn m3-btn-text m3-state m3-ripple mb-4 self-start md:hidden"
          >
            ← Back to sources
          </button>

          <div
            :if={@show_add or @source_count == 0}
            id="add-source-panel"
            class="mx-auto w-full max-w-[560px]"
          >
            <h2 class="text-2xl font-semibold">
              {if @source_count == 0, do: "Add your first source", else: "Add source"}
            </h2>
            <p class="mt-2 text-sm leading-6 text-m3-on-surface-variant">
              Paste an RSS or Atom URL. Readout will fetch new articles, summarize them,
              and add them to your daily digest.
            </p>

            <.form for={@source_form} id="source-form" phx-submit="add_source" class="mt-6">
              <.input
                field={@source_form[:url]}
                type="url"
                label="RSS or Atom URL"
                placeholder="https://example.com/feed.xml"
                autocomplete="url"
                required
              />
              <p :if={@form_error} id="source-form-error" class="m3-field-msg">
                <.icon name="hero-exclamation-circle" class="size-5" />
                {@form_error}
              </p>
              <button type="submit" class="m3-btn m3-btn-filled m3-state m3-ripple mt-4">
                Add source
              </button>
            </.form>
          </div>

          <article :if={@selected && !@show_add} class="mx-auto w-full max-w-[640px]">
            <div class="flex items-center gap-4">
              <span
                class="msym grid size-14 shrink-0 place-items-center rounded-full bg-m3-primary-container text-2xl text-m3-on-primary-container"
                aria-hidden="true"
              >
                rss_feed
              </span>
              <div class="min-w-0">
                <h1 class="truncate text-2xl font-semibold leading-tight">{@selected.name}</h1>
                <a
                  href={@selected.canonical_url}
                  target="_blank"
                  rel="noopener"
                  class="break-all text-sm text-m3-primary hover:underline"
                >
                  {host(@selected.canonical_url)}
                </a>
              </div>
            </div>

            <dl class="m3-card mt-6 divide-y divide-m3-outline-variant bg-m3-surface-container-low p-0">
              <.stat_row icon="update" label="Latest article" value={relative_time(@latest_at)} />
              <.stat_row
                icon="article"
                label="Total articles"
                value={Integer.to_string(@selected.article_count)}
              />
              <.stat_row
                icon="task_alt"
                label="Summaries ready"
                value={Integer.to_string(@selected.summary_count)}
              />
            </dl>

            <h2 class="mt-8 text-sm font-medium text-m3-primary">Recent articles</h2>
            <ul :if={@recent_articles != []} class="mt-2 flex flex-col" role="list">
              <li :for={article <- @recent_articles}>
                <.recent_article article={article} />
              </li>
            </ul>
            <p :if={@recent_articles == []} class="mt-2 text-sm text-m3-on-surface-variant">
              No articles fetched yet. Readout checks for new articles regularly.
            </p>
          </article>

          <div
            :if={!@selected && !@show_add && @source_count > 0}
            id="source-detail-empty"
            class="grid h-full place-items-center px-6 text-center"
          >
            <div>
              <span class="msym text-5xl text-m3-outline" aria-hidden="true">rss_feed</span>
              <h2 class="mt-3 text-lg font-semibold">Select a source</h2>
              <p class="mt-1 text-sm text-m3-on-surface-variant">
                Pick a source from the list to see its health and recent articles.
              </p>
            </div>
          </div>
        </div>
      </section>
    </Layouts.product_shell>
    """
  end

  attr :icon, :string, required: true
  attr :label, :string, required: true
  attr :value, :string, required: true

  defp stat_row(assigns) do
    ~H"""
    <div class="flex items-center gap-3 px-4 py-3.5">
      <span class="msym text-xl text-m3-on-surface-variant" aria-hidden="true">{@icon}</span>
      <span class="flex-1 text-sm text-m3-on-surface-variant">{@label}</span>
      <span class="text-sm font-medium">{@value}</span>
    </div>
    """
  end

  attr :article, :map, required: true

  defp recent_article(%{article: %{summary: %{id: _}}} = assigns) do
    ~H"""
    <.link
      patch={~p"/digest/#{@article.summary.id}"}
      class="m3-state m3-ripple block rounded-xl px-3 py-3 text-sm font-medium leading-snug"
    >
      {@article.title}
    </.link>
    """
  end

  defp recent_article(assigns) do
    ~H"""
    <span class="block rounded-xl px-3 py-3 text-sm leading-snug text-m3-on-surface-variant">
      {@article.title}
    </span>
    """
  end

  defp select_source(socket, entry) do
    articles = Ingestion.list_articles(socket.assigns.current_scope, entry.id)

    latest_at =
      case articles do
        [article | _] -> article.published_at || article.inserted_at
        [] -> nil
      end

    socket
    |> assign(:selected, entry)
    |> assign(:show_add, false)
    |> assign(:recent_articles, Enum.take(articles, 6))
    |> assign(:latest_at, latest_at)
  end

  defp assign_sources(socket) do
    sources = Ingestion.list_source_management_entries(socket.assigns.current_scope)

    socket
    |> assign(:sources, sources)
    |> assign(:source_count, length(sources))
  end

  defp assign_form(socket, url \\ "") do
    assign(socket, :source_form, to_form(%{"url" => url || ""}, as: :source))
  end

  defp selected?(nil, _source), do: false
  defp selected?(selected, source), do: selected.id == source.id

  defp host(url) do
    case URI.parse(url) do
      %URI{host: host} when is_binary(host) -> String.replace_prefix(host, "www.", "")
      _ -> url
    end
  end

  defp relative_time(nil), do: "—"

  defp relative_time(%DateTime{} = at) do
    diff = DateTime.diff(DateTime.utc_now(), at, :second)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)} min ago"
      diff < 86_400 -> pluralize(div(diff, 3600), "hour") <> " ago"
      diff < 2_592_000 -> pluralize(div(diff, 86_400), "day") <> " ago"
      true -> Calendar.strftime(at, "%b %-d, %Y")
    end
  end

  defp pluralize(1, singular), do: "1 #{singular}"
  defp pluralize(count, "Summary"), do: "#{count} Summaries"
  defp pluralize(count, singular), do: "#{count} #{singular}s"

  defp error_message(:invalid_source_url) do
    "Enter a valid RSS or Atom URL, starting with https:// or http://."
  end

  defp error_message({:feed_unreachable, status}) do
    "Readout could not reach that feed (HTTP #{status}). Check the URL or try again later."
  end

  defp error_message(:feed_unreachable) do
    "Readout could not reach that feed. Check the URL or try again later."
  end

  defp error_message(:invalid_rss_format) do
    "That URL did not return a valid RSS or Atom feed. Try the feed URL instead of a webpage."
  end

  defp error_message(_reason) do
    "Readout could not add that source. Check the URL and try again."
  end
end
