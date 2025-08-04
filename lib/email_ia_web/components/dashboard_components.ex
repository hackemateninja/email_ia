defmodule EmailIaWeb.DashboardComponents do
  @moduledoc """
  Provides components for the dashboard.
  """
  use Phoenix.Component
  import EmailIaWeb.CoreComponents

  attr :rest, :global
  slot :inner_block, required: true

  def dashboard_container(assigns) do
    ~H"""
    <div {@rest} class="min-h-screen bg-gray-200 p-6">
      <div class="max-w-7xl mx-auto">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true

  def dashboard_header(assigns) do
    ~H"""
    <div class="mb-8">
      <h1 class="text-3xl  text-gray-900 ">{@title}</h1>
      <p class="text-gray-600 font-light text-sm">{@description}</p>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :button_text, :string, required: true
  attr :button_action, :any, required: true

  def dashboard_header_with_action(assigns) do
    ~H"""
    <div class="mb-8">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-3xl  text-gray-900 ">{@title}</h1>
          <p class="text-gray-600 font-light text-sm">{@description}</p>
        </div>
        <.dashboard_button phx-click={@button_action}>
          <.icon name="hero-plus" class="w-4 h-4" />
          <span>{@button_text}</span>
        </.dashboard_button>
      </div>
    </div>
    """
  end

  attr :rest, :global
  slot :inner_block, required: true

  def dashboard_four_cols(assigns) do
    ~H"""
    <div {@rest} class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-4">
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :rest, :global
  slot :inner_block, required: true

  def dashboard_three_cols(assigns) do
    ~H"""
    <div {@rest} class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :rest, :global
  slot :inner_block, required: true

  def dashboard_two_cols(assigns) do
    ~H"""
    <div {@rest} class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-4">
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :title, :string, required: true
  attr :icon, :string, required: true
  attr :value, :integer, required: true

  def dashboard_stat_card(assigns) do
    ~H"""
    <div class="bg-white rounded-none p-2 border-l-4 border-[#0f62fe]">
      <div class="flex items-center">
        <div class="p-2 rounded-none bg-[#0f62fe] text-white">
          <.icon name={@icon} class="w-5 h-5" />
        </div>
        <div class="ml-2">
          <p class="text-xs text-gray-600">{@title}</p>
          <p class="text-lg  text-gray-900">{@value}</p>
        </div>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :link, :string, required: true
  slot :inner_block, required: true

  def dashboard_list_card(assigns) do
    ~H"""
    <div class="bg-white rounded-none p-2">
      <div class="flex items-center justify-between mb-2">
        <h3 class=" text-gray-900">{@title}</h3>
        <a href={@link} class="text-blue-600 hover:text-blue-800 text-xs font-light">
          View all
        </a>
      </div>
      <div class="space-y-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :subject, :string, required: true
  attr :from, :string, required: true
  attr :inserted_at, :string, required: true
  attr :rest, :global

  def dashboard_list_email_item(assigns) do
    ~H"""
    <div {@rest} class="flex items-start space-x-2 p-2 rounded-none hover:bg-gray-50">
      <div class="flex-shrink-0">
        <.icon name="hero-envelope" class="w-4 h-4 text-gray-500" />
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-xs  text-gray-900 truncate">{@subject}</p>
        <p class="text-xs text-gray-500 truncate">From: {@from}</p>
        <p class="text-xs font-extralight text-gray-400">
          {format_datetime(@inserted_at)}
        </p>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :description, :string, required: true
  attr :email_count, :integer, required: true
  attr :rest, :global

  def dashboard_list_category_item(assigns) do
    ~H"""
    <div {@rest} class="flex items-center justify-between p-2 rounded-none hover:bg-gray-50">
      <div class="flex items-center space-x-2">
        <div>
          <p class="text-xs text-gray-900">{@name}</p>
          <p class="text-xs text-gray-500">{@description}</p>
        </div>
      </div>
      <span class="text-xs font-extralight text-gray-500">
        {@email_count} emails
      </span>
    </div>
    """
  end

  attr :icon, :string, required: true
  attr :message, :string, required: true
  attr :rest, :global

  def dashboard_list_empty(assigns) do
    ~H"""
    <div {@rest} class="text-center py-4 text-gray-500">
      <.icon name={@icon} class="w-4 h-4 text-gray-500" />
      <p>{@message}</p>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :description, :string, required: true
  attr :email_count, :integer, required: true
  attr :inserted_at, :string, required: true
  attr :edit_category, :any, required: true
  attr :delete_category, :any, required: true
  attr :rest, :global

  def dashboard_category_card(assigns) do
    ~H"""
    <div {@rest} class="bg-white rounded-none hover:shadow-xl transition-shadow duration-300">
      <div class="p-2">
        <div class="flex items-start justify-between mb-2">
          <div class="flex items-center space-x-2">
            <div class="w-10 h-10 bg-[#0f62fe] text-white rounded-none flex items-center justify-center">
              <.icon name="hero-tag" class="w-4 h-4" />
            </div>
            <div>
              <h3 class="font-semibold text-gray-900">{@name}</h3>
              <p class="text-xs text-gray-500">{@email_count} emails</p>
            </div>
          </div>
          <div class="flex items-center space-x-2">
            <button
              phx-click={@edit_category}
              class="text-gray-400 hover:text-[#0f62fe] transition-colors"
            >
              <.icon name="hero-pencil" class="w-4 h-4" />
            </button>
            <button
              phx-click={@delete_category}
              data-confirm="Are you sure you want to delete this category?"
              class="text-gray-400 hover:text-[#0f62fe] transition-colors"
            >
              <.icon name="hero-trash" class="w-4 h-4" />
            </button>
          </div>
        </div>

        <p class="text-gray-600 text-xs mb-2 line-clamp-2">{@description}</p>

        <div class="flex items-center justify-between">
          <span class="text-xs font-extralight text-gray-400">
            Created {format_date(@inserted_at)}
          </span>
          <.link navigate={"/dashboard/categories/#{@id}"}>
            <span class="text-xs text-gray-600 hover:text-[#0f62fe] cursor-pointer">
              View Details
            </span>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  attr :kind, :atom, values: [:primary, :black, :danger], default: :primary
  attr :rest, :global
  slot :inner_block, required: true

  def dashboard_button(assigns) do
    ~H"""
    <button
      {@rest}
      class={[
        "bg-[#0f62fe] hover:bg-[#0f62fe] text-white px-4 py-2 rounded-none text-sm font-light",
        @kind == :black && "bg-black hover:bg-black",
        @kind == :danger && "bg-red-500 hover:bg-red-600"
      ]}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :button_text, :string, required: true
  attr :button_action, :any, required: true

  def dashboard_empty_page(assigns) do
    ~H"""
    <div class="text-center py-16">
      <div class="w-24 h-24 bg-blue-100 rounded-none flex items-center justify-center mx-auto mb-2">
        <.icon name={@icon} class="w-12 h-12 text-gray-500" />
      </div>
      <h3 class="text-lg font-semibold text-gray-900 mb-2">{@title}</h3>
      <p class="text-gray-600 mb-4 text-sm">
        {@description}
      </p>
      <.dashboard_button phx-click={@button_action}>
        <span>{@button_text}</span>
      </.dashboard_button>
    </div>
    """
  end

  defp format_datetime(datetime) do
    datetime
    |> Calendar.strftime("%b %d, %Y at %I:%M %p")
    |> to_string()
  end

  defp format_date(datetime) do
    datetime
    |> Calendar.strftime("%b %d, %Y")
    |> to_string()
  end
end
