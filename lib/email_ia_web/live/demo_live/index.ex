defmodule EmailIaWeb.DemoLive.Index do
  use EmailIaWeb, :live_view

  alias EmailIa.Demos
  alias EmailIa.Demos.Demo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :demos, Demos.list_demos())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Demo")
    |> assign(:demo, Demos.get_demo!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Demo")
    |> assign(:demo, %Demo{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Demos")
    |> assign(:demo, nil)
  end

  @impl true
  def handle_info({EmailIaWeb.DemoLive.FormComponent, {:saved, demo}}, socket) do
    {:noreply, stream_insert(socket, :demos, demo)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    demo = Demos.get_demo!(id)
    {:ok, _} = Demos.delete_demo(demo)

    {:noreply, stream_delete(socket, :demos, demo)}
  end
end
