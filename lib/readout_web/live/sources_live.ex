defmodule ReadoutWeb.SourcesLive do
  use ReadoutWeb, :live_view

  alias Readout.Ingestion

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form_error, nil)
      |> assign(:show_add_source_panel, false)
      |> assign(:source_count, 0)
      |> assign_form()
      |> stream(:sources, [])

    {:ok, if(connected?(socket), do: assign_sources(socket), else: socket)}
  end

  @impl true
  def handle_event("show_add_source", _params, socket) do
    {:noreply,
     socket
     |> assign(:form_error, nil)
     |> assign(:show_add_source_panel, true)
     |> assign_form()}
  end

  @impl true
  def handle_event("add_source", %{"source" => source_params}, socket) do
    case Ingestion.subscribe_source(socket.assigns.current_scope, source_params) do
      {:ok, _source} ->
        {:noreply,
         socket
         |> put_flash(:info, "Source added. Fetching articles now.")
         |> assign(:form_error, nil)
         |> assign(:show_add_source_panel, false)
         |> assign_form()
         |> assign_sources()}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:form_error, error_message(reason))
         |> assign(:show_add_source_panel, true)
         |> assign_form(source_params["url"])}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.product_shell flash={@flash} current_scope={@current_scope} active_product={:sources}>
      <section class="mx-auto flex w-full max-w-5xl flex-col gap-6" aria-label="Sources">
        <header class="flex flex-col gap-2">
          <p class="text-sm font-medium text-m3-on-surface-variant">Sources</p>
          <h1 class="text-2xl font-semibold">Manage sources</h1>
          <p class="max-w-2xl text-sm leading-6 text-m3-on-surface-variant">
            Add RSS and Atom sources for Readout to follow. New articles will be fetched,
            summarized, and added to your daily digest.
          </p>
        </header>

        <div
          :if={@source_count == 0 or @show_add_source_panel}
          id="add-source-panel"
          class="m3-card border border-m3-outline-variant p-6 sm:p-8"
        >
          <h2 class="text-lg font-semibold">
            {if @source_count == 0, do: "Add your first source", else: "Add source"}
          </h2>
          <p class="mt-2 max-w-2xl text-sm leading-6 text-m3-on-surface-variant">
            Paste an RSS or Atom URL. Readout will fetch new articles and prepare summaries
            for your digest.
          </p>

          <.form for={@source_form} id="source-form" phx-submit="add_source" class="mt-5 max-w-2xl">
            <.input
              field={@source_form[:url]}
              type="url"
              label="RSS or Atom URL"
              placeholder="https://example.com/feed.xml"
              autocomplete="url"
              required
            />
            <p
              :if={@form_error}
              id="source-form-error"
              class="m3-field-msg"
            >
              <.icon name="hero-exclamation-circle" class="size-5" />
              {@form_error}
            </p>
            <button type="submit" class="m3-btn m3-btn-filled m3-state m3-ripple mt-3">
              Add source
            </button>
          </.form>
        </div>

        <div
          :if={@source_count > 0}
          class="m3-card border border-m3-outline-variant p-0"
        >
          <div class="flex flex-col gap-3 border-b border-m3-outline-variant px-5 py-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h2 class="font-semibold">Your sources</h2>
              <p class="mt-1 text-sm text-m3-on-surface-variant">
                Review source health and add another Source when you need more coverage.
              </p>
            </div>
            <button
              id="show-add-source"
              type="button"
              phx-click="show_add_source"
              class="m3-btn m3-btn-tonal m3-state m3-ripple w-fit"
            >
              Add source
            </button>
          </div>
          <ul
            id="source-list"
            phx-update="stream"
            class="divide-y divide-m3-outline-variant"
            role="list"
          >
            <li :for={{dom_id, source} <- @streams.sources} id={dom_id} class="px-5 py-4">
              <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <div class="min-w-0">
                  <p class="font-medium">{source.name}</p>
                  <p class="mt-1 break-all text-sm text-m3-on-surface-variant">
                    {source.canonical_url}
                  </p>
                </div>
                <div class="flex flex-wrap gap-2 text-sm sm:justify-end">
                  <span class="rounded-full bg-m3-secondary-container px-3 py-1 font-medium text-m3-on-secondary-container">
                    {source.status}
                  </span>
                  <span class="rounded-full border border-m3-outline-variant px-3 py-1 text-m3-on-surface-variant">
                    {pluralize(source.article_count, "Article")}
                  </span>
                  <span class="rounded-full border border-m3-outline-variant px-3 py-1 text-m3-on-surface-variant">
                    {pluralize(source.summary_count, "Summary")}
                  </span>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </section>
    </Layouts.product_shell>
    """
  end

  defp assign_sources(socket) do
    sources = Ingestion.list_source_management_entries(socket.assigns.current_scope)

    socket
    |> assign(:source_count, length(sources))
    |> stream(:sources, sources, reset: true)
  end

  defp pluralize(count, singular) when count == 1, do: "1 #{singular}"
  defp pluralize(count, "Summary"), do: "#{count} Summaries"
  defp pluralize(count, singular), do: "#{count} #{singular}s"

  defp assign_form(socket, url \\ "") do
    assign(socket, :source_form, to_form(%{"url" => url || ""}, as: :source))
  end

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
