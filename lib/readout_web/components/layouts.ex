defmodule ReadoutWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use ReadoutWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="flex items-center gap-4 px-4 py-3 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="32" height="32" alt="" />
          <span class="text-sm font-semibold tracking-wide text-m3-on-surface">Readout</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex items-center gap-3 text-sm text-m3-on-surface-variant">
          <li :if={@current_scope} class="hidden sm:block">
            {@current_scope.user.email}
          </li>
          <li :if={@current_scope}>
            <.link href={~p"/users/settings"} class="hover:text-m3-primary">Settings</.link>
          </li>
          <li :if={@current_scope}>
            <.link href={~p"/users/log-out"} method="delete" class="hover:text-m3-primary">
              Log out
            </.link>
          </li>
          <li :if={!@current_scope}>
            <.link href={~p"/users/log-in"} class="hover:text-m3-primary">Log in</.link>
          </li>
          <li>
            <.theme_toggle />
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Renders the signed-in product shell used by per-User product surfaces.

  Public and authentication pages should continue to use `app/1`; this shell is
  intentionally reserved for authenticated product routes such as Digest.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    required: true,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :active_product, :atom,
    required: true,
    values: [:digest, :sources],
    doc: "which product navigation item should be marked current"

  slot :inner_block, required: true

  def product_shell(assigns) do
    ~H"""
    <div id="product-shell" class="min-h-screen bg-m3-surface text-m3-on-surface md:flex">
      <aside class="hidden w-64 shrink-0 border-r border-m3-outline-variant bg-m3-surface-container-low md:flex md:min-h-screen md:flex-col">
        <div class="flex h-20 items-center px-6">
          <a href={~p"/digest"} class="flex w-fit items-center gap-3">
            <img src={~p"/images/logo.svg"} width="36" height="36" alt="" />
            <span class="text-base font-semibold tracking-wide">Readout</span>
          </a>
        </div>

        <nav aria-label="Product" class="flex-1 px-3 py-2">
          <ul class="space-y-1">
            <li>
              <.product_nav_link href={~p"/digest"} active={@active_product == :digest}>
                <:icon>article</:icon>
                Digest
              </.product_nav_link>
            </li>
            <li>
              <.product_nav_link href="/sources" active={@active_product == :sources}>
                <:icon>rss_feed</:icon>
                Sources
              </.product_nav_link>
            </li>
          </ul>
        </nav>
      </aside>

      <div class="min-w-0 flex-1">
        <header class="sticky top-0 z-30 border-b border-m3-outline-variant bg-m3-surface/95 backdrop-blur supports-[backdrop-filter]:bg-m3-surface/80">
          <div class="flex min-h-16 flex-wrap items-center gap-3 px-4 py-3 sm:px-6 lg:px-8">
            <a href={~p"/digest"} class="flex items-center gap-2 md:hidden">
              <img src={~p"/images/logo.svg"} width="32" height="32" alt="" />
              <span class="text-sm font-semibold tracking-wide">Readout</span>
            </a>

            <nav aria-label="Product" class="order-3 w-full md:hidden">
              <ul class="flex gap-2">
                <li>
                  <.product_nav_link href={~p"/digest"} active={@active_product == :digest} compact>
                    <:icon>article</:icon>
                    Digest
                  </.product_nav_link>
                </li>
                <li>
                  <.product_nav_link href="/sources" active={@active_product == :sources} compact>
                    <:icon>rss_feed</:icon>
                    Sources
                  </.product_nav_link>
                </li>
              </ul>
            </nav>

            <div class="ml-auto flex items-center gap-3 text-sm text-m3-on-surface-variant">
              <span class="hidden max-w-[18rem] truncate sm:inline">{@current_scope.user.email}</span>
              <.link href={~p"/users/settings"} class="hover:text-m3-primary">Settings</.link>
              <.link href={~p"/users/log-out"} method="delete" class="hover:text-m3-primary">
                Log out
              </.link>
              <.theme_toggle />
            </div>
          </div>
        </header>

        <main class="px-4 py-6 sm:px-6 lg:px-8">
          {render_slot(@inner_block)}
        </main>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :href, :string, required: true
  attr :active, :boolean, required: true
  attr :compact, :boolean, default: false
  slot :icon, required: true
  slot :inner_block, required: true

  defp product_nav_link(assigns) do
    ~H"""
    <.link
      href={@href}
      aria-current={if @active, do: "page"}
      class={[
        "m3-state m3-ripple flex items-center gap-3 rounded-full px-4 text-sm font-medium transition-colors",
        @compact && "h-10",
        !@compact && "h-12",
        if(@active,
          do: "bg-m3-secondary-container text-m3-on-secondary-container",
          else: "text-m3-on-surface-variant hover:text-m3-on-surface"
        )
      ]}
    >
      <span class="msym text-xl" aria-hidden="true">{render_slot(@icon)}</span>
      <span>{render_slot(@inner_block)}</span>
    </.link>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div
      id={@id}
      aria-live="polite"
      class="pointer-events-none fixed top-4 right-4 z-50 flex w-80 max-w-[calc(100vw-2rem)] flex-col gap-2 sm:w-96"
    >
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="relative flex flex-row items-center rounded-full border border-m3-outline-variant bg-m3-surface-container">
      <div class="absolute left-0 h-full w-1/3 rounded-full bg-m3-secondary-container [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="relative flex w-1/3 cursor-pointer justify-center p-2 text-m3-on-surface-variant"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
        aria-label="Use system theme"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="relative flex w-1/3 cursor-pointer justify-center p-2 text-m3-on-surface-variant"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
        aria-label="Use light theme"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="relative flex w-1/3 cursor-pointer justify-center p-2 text-m3-on-surface-variant"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
        aria-label="Use dark theme"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
