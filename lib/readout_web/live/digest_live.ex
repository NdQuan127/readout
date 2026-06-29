defmodule ReadoutWeb.DigestLive do
  use ReadoutWeb, :live_view

  alias Readout.{Curation, Ingestion}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Curation.subscribe_today_digest(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:filter, "all")
     |> assign(:selected, nil)
     |> assign(:digest_update_available, false)
     |> assign_digest()}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    case params["id"] do
      nil ->
        socket =
          socket
          |> assign(:selected, nil)
          |> refresh_digest_if_update_available()

        {:noreply, socket}

      id ->
        case find_item(socket.assigns.digest, id) do
          nil -> {:noreply, push_patch(socket, to: ~p"/digest")}
          item -> {:noreply, assign(socket, :selected, item.summary)}
        end
    end
  end

  @impl true
  def handle_event("generate", _params, socket) do
    {:ok, _digest} = Curation.generate_digest(socket.assigns.current_scope, Date.utc_today())

    {:noreply, refresh_digest_list(socket, reset_filter?: true)}
  end

  @impl true
  def handle_event("refresh-list", _params, socket) do
    {:noreply, refresh_digest_list(socket)}
  end

  @impl true
  def handle_event("filter", %{"source" => source}, socket) do
    {:noreply, assign(socket, :filter, source)}
  end

  @impl true
  def handle_info({:digest_updated, _date}, %{assigns: %{selected: nil}} = socket) do
    {:noreply,
     socket
     |> assign(:digest_update_available, false)
     |> assign_digest()}
  end

  @impl true
  def handle_info({:digest_updated, _date}, socket) do
    {:noreply, assign(socket, :digest_update_available, true)}
  end

  @impl true
  def render(assigns) do
    items = items(assigns.digest)

    assigns =
      assigns
      |> assign(:items, items)
      |> assign(:sources, list_sources(items))

    ~H"""
    <Layouts.product_shell flash={@flash} current_scope={@current_scope} active_product={:digest}>
      <section
        class="digest"
        data-detail-open={to_string(@selected != nil)}
        aria-label="Today's digest"
      >
        <div class="digest-list-pane flex flex-col gap-4">
          <header class="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p class="text-sm font-medium text-m3-on-surface-variant">
                {Calendar.strftime(@today, "%b %-d, %Y")}
              </p>
              <h1 class="text-2xl font-semibold">Today's digest</h1>
            </div>

            <button
              :if={@items != []}
              id="generate-digest"
              type="button"
              phx-click="generate"
              class="m3-btn m3-btn-tonal m3-state m3-ripple self-start"
            >
              Regenerate
            </button>
          </header>

          <div
            :if={@digest_update_available}
            id="digest-update-notice"
            class="m3-card flex items-center justify-between gap-3 border border-m3-outline-variant bg-m3-surface-container-low px-4 py-3 text-sm"
          >
            <p class="font-medium">Digest updated</p>
            <button
              type="button"
              phx-click="refresh-list"
              class="m3-btn m3-btn-text m3-state m3-ripple"
            >
              Refresh list
            </button>
          </div>

          <div
            :if={@items != []}
            id="source-filter"
            class="relative max-w-xs"
            phx-click-away={JS.hide(to: "#source-filter-menu")}
          >
            <span id="source-filter-label" class="m3-label">Filter by source</span>
            <button
              type="button"
              phx-click={JS.toggle(to: "#source-filter-menu")}
              aria-haspopup="listbox"
              aria-labelledby="source-filter-label"
              class="m3-select-trigger m3-state m3-ripple"
            >
              <span class="truncate">{filter_label(@filter, @sources)}</span>
              <span class="msym shrink-0 text-xl text-m3-on-surface-variant" aria-hidden="true">
                arrow_drop_down
              </span>
            </button>
            <ul id="source-filter-menu" role="listbox" class="m3-menu hidden">
              <li>
                <button
                  type="button"
                  role="option"
                  aria-selected={to_string(@filter == "all")}
                  phx-click={JS.hide(to: "#source-filter-menu") |> JS.push("filter")}
                  phx-value-source="all"
                  class={["m3-menu-item m3-state m3-ripple", @filter == "all" && "is-selected"]}
                >
                  All sources
                </button>
              </li>
              <li :for={source <- @sources}>
                <button
                  type="button"
                  role="option"
                  aria-selected={to_string(@filter == source.id)}
                  phx-click={JS.hide(to: "#source-filter-menu") |> JS.push("filter")}
                  phx-value-source={source.id}
                  class={["m3-menu-item m3-state m3-ripple", @filter == source.id && "is-selected"]}
                >
                  {source.name}
                </button>
              </li>
            </ul>
          </div>

          <div
            :if={@items == []}
            id="digest-empty"
            class="m3-card bg-m3-surface-container-high p-8 text-center"
          >
            <h2 class="text-lg font-semibold">
              {if @has_sources, do: "No summaries ready yet", else: "No sources yet"}
            </h2>
            <p class="mx-auto mt-2 max-w-xl text-sm text-m3-on-surface-variant">
              <%= if @has_sources do %>
                Readout is still fetching and summarizing articles from your sources.
              <% else %>
                Add an RSS or Atom source. Readout will fetch articles, prepare summaries, and build your daily digest.
              <% end %>
            </p>
            <.link
              id="digest-empty-sources-link"
              navigate={~p"/sources"}
              class="m3-btn m3-btn-filled m3-state m3-ripple mt-6"
            >
              {if @has_sources, do: "View sources", else: "Add source"}
            </.link>
          </div>

          <ul :if={@items != []} id="digest-items" class="flex flex-col gap-3" role="list">
            <li
              :for={{item, i} <- Enum.with_index(visible_items(@items, @filter))}
              id={"digest-item-#{item.summary.id}"}
              style={"animation-delay:#{i * 40}ms"}
              aria-current={to_string(selected?(@selected, item.summary))}
            >
              <.link
                patch={~p"/digest/#{item.summary.id}"}
                class={[
                  "m3-card m3-state m3-ripple block p-4 transition-transform duration-200",
                  if(selected?(@selected, item.summary),
                    do: "bg-m3-secondary-container text-m3-on-secondary-container",
                    else:
                      "bg-m3-surface-container-high shadow-[0_1px_2px_rgb(0_0_0/0.04)] hover:-translate-y-0.5"
                  )
                ]}
              >
                <p class="text-xs font-medium text-m3-on-surface-variant">
                  {item.summary.article.source.name}
                  <span>
                    · Ready {Calendar.strftime(item.summary.inserted_at, "%b %-d, %H:%M")}
                  </span>
                </p>
                <p data-role="item-title" class="mt-1 font-semibold leading-snug">
                  {item.summary.article.title}
                </p>
                <p
                  data-role="item-preview"
                  class="mt-2 line-clamp-2 text-sm leading-6 text-m3-on-surface-variant"
                >
                  {summary_preview(item.summary.summary_text)}
                </p>
                <div :if={item.summary.tags != []} class="mt-2 flex flex-wrap gap-1.5">
                  <span :for={tag <- item.summary.tags} class="m3-chip">{tag}</span>
                </div>
              </.link>
            </li>
          </ul>
        </div>

        <div
          id="detail-pane"
          class={["digest-detail", @selected && "detail-open"]}
          aria-live="polite"
        >
          <.link
            :if={@selected}
            patch={~p"/digest"}
            class="m3-btn m3-btn-text m3-state m3-ripple mb-4 self-start md:hidden"
          >
            ← Back to list
          </.link>

          <article :if={@selected} class="mx-auto w-full max-w-[680px]">
            <p class="text-xs font-medium text-m3-on-surface-variant">
              {@selected.article.source.name}
              <span :if={@selected.article.published_at}>
                · {Calendar.strftime(@selected.article.published_at, "%b %-d, %H:%M")}
              </span>
            </p>
            <h1 class="mt-2 text-2xl font-semibold leading-tight">{@selected.article.title}</h1>
            <div :if={@selected.tags != []} class="mt-3 flex flex-wrap gap-1.5">
              <span :for={tag <- @selected.tags} class="m3-chip">{tag}</span>
            </div>
            <div class="reading mt-6">
              {render_markdown(@selected.summary_text)}
            </div>
            <a
              href={@selected.article.canonical_url}
              target="_blank"
              rel="noopener"
              class="m3-btn m3-btn-outlined m3-state m3-ripple mt-8"
            >
              Read original
            </a>
          </article>

          <div
            :if={!@selected}
            id="detail-empty"
            class="grid h-full place-items-center px-6 text-center"
          >
            <div>
              <span class="msym text-5xl text-m3-outline" aria-hidden="true">
                article
              </span>
              <h2 class="mt-3 text-lg font-semibold">Select an article</h2>
              <p class="mt-1 text-sm text-m3-on-surface-variant">
                Pick a story from the list to read its summary here.
              </p>
            </div>
          </div>
        </div>
      </section>
    </Layouts.product_shell>
    """
  end

  defp assign_digest(socket) do
    scope = socket.assigns.current_scope

    socket
    |> assign(:today, Date.utc_today())
    |> assign(:digest, Curation.get_today_digest(scope))
    |> assign(:has_sources, Ingestion.list_sources(scope) != [])
  end

  defp refresh_digest_if_update_available(%{assigns: %{digest_update_available: true}} = socket) do
    refresh_digest_list(socket)
  end

  defp refresh_digest_if_update_available(socket), do: socket

  defp refresh_digest_list(socket, opts \\ []) do
    selected_id = socket.assigns.selected && socket.assigns.selected.id

    socket =
      socket
      |> maybe_reset_filter(opts)
      |> assign(:digest_update_available, false)
      |> assign_digest()

    case selected_id do
      nil ->
        socket

      id ->
        case find_item(socket.assigns.digest, id) do
          nil ->
            socket
            |> assign(:selected, nil)
            |> push_patch(to: ~p"/digest")

          item ->
            assign(socket, :selected, item.summary)
        end
    end
  end

  defp maybe_reset_filter(socket, opts) do
    if Keyword.get(opts, :reset_filter?, false) do
      assign(socket, :filter, "all")
    else
      socket
    end
  end

  defp items(nil), do: []
  defp items(%{items: items}), do: items

  defp find_item(digest, summary_id), do: Enum.find(items(digest), &(&1.summary.id == summary_id))

  defp visible_items(items, "all"), do: items

  defp visible_items(items, source_id),
    do: Enum.filter(items, &(&1.summary.article.source_id == source_id))

  defp filter_label("all", _sources), do: "All sources"

  defp filter_label(source_id, sources) do
    case Enum.find(sources, &(&1.id == source_id)) do
      nil -> "All sources"
      source -> source.name
    end
  end

  defp list_sources(items) do
    items
    |> Enum.map(& &1.summary.article.source)
    |> Enum.uniq_by(& &1.id)
    |> Enum.sort_by(& &1.name)
  end

  defp summary_preview(summary_text) do
    summary_text
    |> String.replace(~r/<script\b[^>]*>.*?<\/script>/is, " ")
    |> String.replace(~r/<[^>]*>/, " ")
    |> String.replace(~r/[#*_>`\[\]()!-]/, " ")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.slice(0, 180)
  end

  defp selected?(nil, _summary), do: false
  defp selected?(selected, summary), do: selected.id == summary.id
end
