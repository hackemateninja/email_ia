defmodule EmailIaWeb.CategoriesLive do
  use EmailIaWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h1>Categories</h1>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
