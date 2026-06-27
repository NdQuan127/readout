defmodule ReadoutWeb.SourcesLive do
  use ReadoutWeb, :live_view

  alias Readout.Ingestion

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:form_error, nil)
     |> assign_form()
     |> assign_sources()}
  end

  @impl true
  def handle_event("add_source", %{"source" => source_params}, socket) do
    case Ingestion.subscribe_source(socket.assigns.current_scope, source_params) do
      {:ok, _source} ->
        {:noreply,
         socket
         |> put_flash(:info, "Source added. Fetching articles now.")
         |> assign(:form_error, nil)
         |> assign_form()
         |> assign_sources()}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:form_error, error_message(reason))
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
          <div class="border-b border-m3-outline-variant px-5 py-4">
            <h2 class="font-semibold">Your sources</h2>
          </div>
          <ul
            id="source-list"
            phx-update="stream"
            class="divide-y divide-m3-outline-variant"
            role="list"
          >
            <li :for={{dom_id, source} <- @streams.sources} id={dom_id} class="px-5 py-4">
              <p class="font-medium">{source.name}</p>
              <p class="mt-1 break-all text-sm text-m3-on-surface-variant">{source.canonical_url}</p>
            </li>
          </ul>
        </div>
      </section>
    </Layouts.product_shell>
    """
  end

  defp assign_sources(socket) do
    sources = Ingestion.list_sources(socket.assigns.current_scope)

    socket
    |> assign(:source_count, length(sources))
    |> stream(:sources, sources, reset: true)
  end

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
