defmodule EmailIaWeb.DemoLive.Show do
  use EmailIaWeb, :live_view

  alias EmailIa.Demos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:demo, Demos.get_demo!(id))}
  end

  defp page_title(:show), do: "Show Demo"
  defp page_title(:edit), do: "Edit Demo"
end
