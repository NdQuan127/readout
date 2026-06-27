defmodule ReadoutWeb.DigestLive do
  use ReadoutWeb, :live_view

  alias Readout.{Curation, Ingestion}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:filter, "all")
     |> assign(:selected, nil)
     |> assign_digest()}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    case params["id"] do
      nil ->
        {:noreply, assign(socket, :selected, nil)}

      id ->
        case Enum.find(items(socket.assigns.digest), &(&1.summary.id == id)) do
          nil -> {:noreply, push_patch(socket, to: ~p"/digest")}
          item -> {:noreply, assign(socket, :selected, item.summary)}
        end
    end
  end

  @impl true
  def handle_event("generate", _params, socket) do
    {:ok, _digest} = Curation.generate_digest(socket.assigns.current_scope, Date.utc_today())

    {:noreply, socket |> assign(:filter, "all") |> assign_digest()}
  end

  @impl true
  def handle_event("filter", %{"source" => source}, socket) do
    {:noreply, assign(socket, :filter, source)}
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

          <form :if={@items != []} class="max-w-xs">
            <label class="m3-label" for="source-filter">Filter by source</label>
            <select id="source-filter" name="source" phx-change="filter" class="m3-select">
              <option value="all" selected={@filter == "all"}>All sources</option>
              <option
                :for={source <- @sources}
                value={source.id}
                selected={@filter == source.id}
              >
                {source.name}
              </option>
            </select>
          </form>

          <div
            :if={@items == []}
            id="digest-empty"
            class="m3-card border border-m3-outline-variant p-8 text-center"
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
              :for={item <- visible_items(@items, @filter)}
              id={"digest-item-#{item.summary.id}"}
              aria-current={to_string(selected?(@selected, item.summary))}
            >
              <.link
                patch={~p"/digest/#{item.summary.id}"}
                class={[
                  "m3-card m3-state m3-ripple block border p-4",
                  if(selected?(@selected, item.summary),
                    do: "border-m3-primary bg-m3-secondary-container",
                    else: "border-m3-outline-variant"
                  )
                ]}
              >
                <p class="text-xs font-medium text-m3-on-surface-variant">
                  {item.summary.article.source.name}
                  <span :if={item.summary.article.published_at}>
                    · {Calendar.strftime(item.summary.article.published_at, "%b %-d, %H:%M")}
                  </span>
                </p>
                <p data-role="item-title" class="mt-1 font-semibold leading-snug">
                  {item.summary.article.title}
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

          <article :if={@selected} class="m3-card border border-m3-outline-variant p-6">
            <p class="text-xs font-medium text-m3-on-surface-variant">
              {@selected.article.source.name}
              <span :if={@selected.article.published_at}>
                · {Calendar.strftime(@selected.article.published_at, "%b %-d, %H:%M")}
              </span>
            </p>
            <h1 class="mt-1 text-xl font-semibold leading-tight">{@selected.article.title}</h1>
            <div :if={@selected.tags != []} class="mt-3 flex flex-wrap gap-1.5">
              <span :for={tag <- @selected.tags} class="m3-chip">{tag}</span>
            </div>
            <div class="reading mt-5 space-y-3 text-[15px] leading-7 [&_a]:text-m3-primary [&_a]:underline [&_h1]:text-base [&_h1]:font-semibold [&_h2]:text-base [&_h2]:font-semibold [&_ol]:list-decimal [&_ol]:pl-5 [&_ul]:list-disc [&_ul]:pl-5">
              {render_markdown(@selected.summary_text)}
            </div>
            <a
              href={@selected.article.canonical_url}
              target="_blank"
              rel="noopener"
              class="m3-btn m3-btn-outlined m3-state m3-ripple mt-6"
            >
              Read the original
            </a>
          </article>

          <div
            :if={!@selected}
            id="detail-empty"
            class="m3-card grid place-items-center border border-dashed border-m3-outline-variant p-10 text-center"
          >
            <div>
              <span class="msym text-4xl text-m3-on-surface-variant" aria-hidden="true">
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

  defp items(nil), do: []
  defp items(%{items: items}), do: items

  defp visible_items(items, "all"), do: items

  defp visible_items(items, source_id),
    do: Enum.filter(items, &(&1.summary.article.source_id == source_id))

  defp list_sources(items) do
    items
    |> Enum.map(& &1.summary.article.source)
    |> Enum.uniq_by(& &1.id)
    |> Enum.sort_by(& &1.name)
  end

  defp selected?(nil, _summary), do: false
  defp selected?(selected, summary), do: selected.id == summary.id
end
