defmodule EmailIaWeb.DemoLive.FormComponent do
  use EmailIaWeb, :live_component

  alias EmailIa.Demos

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage demo records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="demo-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Demo</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{demo: demo} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Demos.change_demo(demo))
     end)}
  end

  @impl true
  def handle_event("validate", %{"demo" => demo_params}, socket) do
    changeset = Demos.change_demo(socket.assigns.demo, demo_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"demo" => demo_params}, socket) do
    save_demo(socket, socket.assigns.action, demo_params)
  end

  defp save_demo(socket, :edit, demo_params) do
    case Demos.update_demo(socket.assigns.demo, demo_params) do
      {:ok, demo} ->
        notify_parent({:saved, demo})

        {:noreply,
         socket
         |> put_flash(:info, "Demo updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_demo(socket, :new, demo_params) do
    case Demos.create_demo(demo_params) do
      {:ok, demo} ->
        notify_parent({:saved, demo})

        {:noreply,
         socket
         |> put_flash(:info, "Demo created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
