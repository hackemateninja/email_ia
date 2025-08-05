defmodule EmailIaWeb.Dashboard.Category.CategoriesLive do
  use EmailIaWeb, :live_view

  alias EmailIa.Categories.Category

  alias EmailIa.Categories

  @impl true
  def render(assigns) do
    ~H"""
    <.dashboard_container>
      <!-- Header -->
      <.dashboard_header_with_action
        title="Categories"
        description="Organize your emails with custom categories"
        button_text="Add Category"
        button_action={JS.patch(~p"/dashboard/categories/new")}
        icon="hero-plus"
      />

    <!-- Categories Grid -->
      <.dashboard_three_cols id="categories" phx-update="stream">
        <%= for {id, category} <- @streams.categories do %>
          <.dashboard_category_card
            id={id}
            category_id={category.id}
            name={category.name}
            description={category.description}
            inserted_at={category.inserted_at}
            edit_category={JS.patch(~p"/dashboard/categories/#{category.id}/show/edit")}
            delete_category={JS.push("delete", value: %{id: category.id})}
          />
        <% end %>
      </.dashboard_three_cols>

    <!-- Empty State -->

      <.dashboard_empty_page
        :if={@streams.categories == []}
        icon="hero-folder"
        title="No categories yet"
        description="Create your first category to start organizing your emails"
        button_text="Create Your First Category"
        button_action={JS.patch(~p"/dashboard/categories/new")}
      />
    </.dashboard_container>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="category-modal"
      show
      on_cancel={JS.patch(~p"/dashboard/categories")}
    >
      <.live_component
        module={EmailIaWeb.Dashboard.Category.FormComponent}
        id={@category.id || :new}
        title={@page_title}
        action={@live_action}
        category={@category}
        current_user={@current_user}
        patch={~p"/dashboard/categories"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user.id
    {:ok, stream(socket, :categories, Categories.list_categories(current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Categories.get_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Categories")
    |> assign(:category, nil)
  end

  @impl true
  def handle_info({EmailIaWeb.Dashboard.Category.FormComponent, {:saved, category}}, socket) do
    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Categories.get_category!(id)
    {:ok, _} = Categories.delete_category(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end
end
