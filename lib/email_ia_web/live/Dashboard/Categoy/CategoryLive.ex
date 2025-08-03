defmodule EmailIaWeb.CategoryLive do
  use EmailIaWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h1>Category</h1>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
