defmodule ReadoutWeb.DigestLive do
  use ReadoutWeb, :live_view

  alias Readout.Curation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_digest(socket)}
  end

  @impl true
  def handle_event("generate", _params, socket) do
    scope = socket.assigns.current_scope
    today = Date.utc_today()

    {:ok, _digest} = Curation.generate_digest(scope, today)

    {:noreply, assign_digest(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <section class="mx-auto max-w-3xl">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p class="text-sm font-medium text-base-content/60">{@today}</p>
            <h1 class="text-2xl font-semibold">Digest hôm nay</h1>
            <p class="mt-1 text-sm text-base-content/70">{@current_scope.user.email}</p>
          </div>

          <button type="button" phx-click="generate" class="btn btn-primary">
            Tạo digest hôm nay
          </button>
        </div>

        <div
          :if={empty_digest?(@digest)}
          class="mt-10 rounded-box border border-base-300 bg-base-100 p-8 text-center"
        >
          <h2 class="text-lg font-semibold">Chưa có digest hôm nay</h2>
          <p class="mt-2 text-sm text-base-content/70">
            Bấm “Tạo digest hôm nay” để gom các Summary đã hoàn tất từ Source bạn subscribe.
          </p>
        </div>

        <div :if={!empty_digest?(@digest)} id="digest-items" class="mt-8 space-y-5">
          <article
            :for={item <- @digest.items}
            id={"digest-item-#{item.id}"}
            class="rounded-box border border-base-300 bg-base-100 p-5"
          >
            <a href={item.summary.article.canonical_url} class="text-lg font-semibold hover:underline">
              {item.summary.article.title}
            </a>
            <p :if={item.summary.article.published_at} class="mt-1 text-xs text-base-content/60">
              Xuất bản {Calendar.strftime(item.summary.article.published_at, "%Y-%m-%d %H:%M UTC")}
            </p>
            <div class="mt-3 space-y-2 text-sm leading-6 text-base-content/80 [&_a]:link [&_a]:link-primary [&_h1]:text-base [&_h1]:font-semibold [&_h2]:text-base [&_h2]:font-semibold [&_ol]:list-decimal [&_ol]:pl-5 [&_ul]:list-disc [&_ul]:pl-5">
              {render_markdown(item.summary.summary_text)}
            </div>
            <div :if={item.summary.tags != []} class="mt-3 flex flex-wrap gap-2">
              <span :for={tag <- item.summary.tags} class="badge badge-primary">{tag}</span>
            </div>
          </article>
        </div>
      </section>
    </Layouts.app>
    """
  end

  defp assign_digest(socket) do
    socket
    |> assign(:today, Date.utc_today())
    |> assign(:digest, Curation.get_today_digest(socket.assigns.current_scope))
  end

  defp empty_digest?(nil), do: true
  defp empty_digest?(%{items: []}), do: true
  defp empty_digest?(_digest), do: false
end
