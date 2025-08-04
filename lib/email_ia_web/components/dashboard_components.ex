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

  attr :title, :string, required: true
  attr :description, :string, required: true

  def dashboard_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-md p-4">
      <h2 class="text-lg font-bold">{@title}</h2>
      <p class="text-sm text-gray-500">{@description}</p>
    </div>
    """
  end

  defp format_datetime(datetime) do
    datetime
    |> Calendar.strftime("%b %d, %Y at %I:%M %p")
    |> to_string()
  end
end
