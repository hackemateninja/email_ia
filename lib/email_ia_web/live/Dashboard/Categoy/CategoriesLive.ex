defmodule EmailIaWeb.CategoriesLive do
  use EmailIaWeb, :live_view
  import Ecto.Query
  alias EmailIa.Repo
  alias EmailIa.Categories.Category
  alias EmailIa.Emails.Email

  def render(assigns) do
    ~H"""
    <.dashboard_container>
      <!-- Header -->
      <.dashboard_header_with_action
        title="Categories"
        description="Organize your emails with custom categories"
        button_text="Add Category"
        button_action={JS.push("show_create_modal")}
        icon="hero-plus"
      />
      
    <!-- Categories Grid -->
      <.dashboard_three_cols>
        <.dashboard_category_card
          :for={category <- @categories}
          id={category.id}
          name={category.name}
          description={category.description}
          email_count={category.email_count}
          inserted_at={category.inserted_at}
          edit_category={JS.push("edit_category", value: %{id: category.id})}
          delete_category={JS.push("delete_category", value: %{id: category.id})}
        />
      </.dashboard_three_cols>
      
    <!-- Empty State -->

      <.dashboard_empty_page
        :if={Enum.empty?(@categories)}
        icon="hero-folder"
        title="No categories yet"
        description="Create your first category to start organizing your emails"
        button_text="Create Your First Category"
        button_action={JS.push("show_create_modal")}
      />
    </.dashboard_container>
    """
  end

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    socket =
      assign(socket,
        categories: fetch_categories(current_user.id),
        search: "",
        sort_by: "name",
        show_modal: false,
        editing_category: nil,
        category_form: %{"name" => "", "description" => ""}
      )

    {:ok, socket}
  end

  def handle_event("search", %{"value" => search}, socket) do
    socket = assign(socket, search: search)

    categories =
      filter_and_sort_categories(socket.assigns.categories, search, socket.assigns.sort_by)

    {:noreply, assign(socket, categories: categories)}
  end

  def handle_event("sort", %{"value" => sort_by}, socket) do
    socket = assign(socket, sort_by: sort_by)

    categories =
      filter_and_sort_categories(socket.assigns.categories, socket.assigns.search, sort_by)

    {:noreply, assign(socket, categories: categories)}
  end

  def handle_event("show_create_modal", _params, socket) do
    socket =
      assign(socket,
        show_modal: true,
        editing_category: nil,
        category_form: %{"name" => "", "description" => ""}
      )

    {:noreply, socket}
  end

  def handle_event("hide_modal", _params, socket) do
    socket = assign(socket, show_modal: false)
    {:noreply, socket}
  end

  def handle_event("edit_category", %{"id" => id}, socket) do
    category = Repo.get(Category, id)

    socket =
      assign(socket,
        show_modal: true,
        editing_category: category,
        category_form: %{"name" => category.name, "description" => category.description}
      )

    {:noreply, socket}
  end

  def handle_event("save_category", %{"name" => name, "description" => description}, socket) do
    current_user = socket.assigns.current_user

    case socket.assigns.editing_category do
      nil ->
        # Create new category
        category_params = %{
          name: name,
          description: description,
          user_id: current_user.id
        }

        case create_category(category_params) do
          {:ok, _category} ->
            socket =
              assign(socket,
                show_modal: false,
                categories: fetch_categories(current_user.id)
              )

            {:noreply, put_flash(socket, :info, "Category created successfully!")}

          {:error, _changeset} ->
            {:noreply, put_flash(socket, :error, "Failed to create category. Please try again.")}
        end

      category ->
        # Update existing category
        category_params = %{name: name, description: description}

        case update_category(category, category_params) do
          {:ok, _category} ->
            socket =
              assign(socket,
                show_modal: false,
                categories: fetch_categories(current_user.id)
              )

            {:noreply, put_flash(socket, :info, "Category updated successfully!")}

          {:error, _changeset} ->
            {:noreply, put_flash(socket, :error, "Failed to update category. Please try again.")}
        end
    end
  end

  def handle_event("delete_category", %{"id" => id}, socket) do
    current_user = socket.assigns.current_user
    category = Repo.get(Category, id)

    case delete_category(category) do
      {:ok, _category} ->
        socket = assign(socket, categories: fetch_categories(current_user.id))
        {:noreply, put_flash(socket, :info, "Category deleted successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete category. Please try again.")}
    end
  end

  defp fetch_categories(user_id) do
    Repo.all(
      from(c in Category,
        where: c.user_id == ^user_id,
        left_join: e in Email,
        on: e.category_id == c.id,
        group_by: [c.id, c.name, c.description, c.inserted_at],
        select: {c.id, c.name, c.description, c.inserted_at, count(e.id)},
        order_by: [asc: c.name]
      )
    )
    |> Enum.map(fn {id, name, description, inserted_at, count} ->
      %{
        id: id,
        name: name,
        description: description,
        inserted_at: inserted_at,
        email_count: count
      }
    end)
  end

  defp filter_and_sort_categories(categories, search, sort_by) do
    categories
    |> Enum.filter(fn category ->
      String.contains?(String.downcase(category.name), String.downcase(search)) or
        String.contains?(String.downcase(category.description), String.downcase(search))
    end)
    |> Enum.sort_by(
      fn category ->
        case sort_by do
          "name" -> category.name
          "email_count" -> category.email_count
          "created_at" -> category.inserted_at
          _ -> category.name
        end
      end,
      case sort_by do
        "email_count" -> :desc
        "created_at" -> :desc
        _ -> :asc
      end
    )
  end

  defp create_category(params) do
    %Category{}
    |> Category.changeset(params)
    |> Repo.insert()
  end

  defp update_category(category, params) do
    category
    |> Category.changeset(params)
    |> Repo.update()
  end

  defp delete_category(category) do
    Repo.delete(category)
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y")
  end
end
