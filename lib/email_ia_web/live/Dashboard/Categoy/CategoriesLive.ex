defmodule EmailIaWeb.CategoriesLive do
  use EmailIaWeb, :live_view
  import Ecto.Query
  alias EmailIa.Repo
  alias EmailIa.Categories.Category
  alias EmailIa.Emails.Email

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-200 p-6">
      <div class="max-w-7xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-4xl font-bold text-gray-900 mb-2">Categories</h1>
              <p class="text-gray-600">Organize your emails with custom categories</p>
            </div>
            <button
              phx-click="show_create_modal"
              class="bg-purple-600 hover:bg-purple-700 text-white px-6 py-3 rounded-lg font-medium flex items-center space-x-2 transition-colors"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                >
                </path>
              </svg>
              <span>Add Category</span>
            </button>
          </div>
        </div>
        
    <!-- Search and Filters -->
        <div class="bg-white rounded-xl shadow-lg p-6 mb-6">
          <div class="flex items-center space-x-4">
            <div class="flex-1">
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg
                    class="h-5 w-5 text-gray-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                    >
                    </path>
                  </svg>
                </div>
                <input
                  type="text"
                  placeholder="Search categories..."
                  phx-keyup="search"
                  phx-debounce="300"
                  value={@search}
                  class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                />
              </div>
            </div>
            <div class="flex items-center space-x-2">
              <span class="text-sm text-gray-600">Sort by:</span>
              <select
                phx-change="sort"
                value={@sort_by}
                class="border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
              >
                <option value="name">Name</option>
                <option value="email_count">Email Count</option>
                <option value="created_at">Created Date</option>
              </select>
            </div>
          </div>
        </div>
        
    <!-- Categories Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <%= for category <- @categories do %>
            <div class="bg-white rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-300">
              <div class="p-6">
                <div class="flex items-start justify-between mb-4">
                  <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                      <svg
                        class="w-6 h-6 text-purple-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
                        >
                        </path>
                      </svg>
                    </div>
                    <div>
                      <h3 class="text-lg font-semibold text-gray-900">{category.name}</h3>
                      <p class="text-sm text-gray-500">{category.email_count} emails</p>
                    </div>
                  </div>
                  <div class="flex items-center space-x-2">
                    <button
                      phx-click="edit_category"
                      phx-value-id={category.id}
                      class="text-gray-400 hover:text-purple-600 transition-colors"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                        >
                        </path>
                      </svg>
                    </button>
                    <button
                      phx-click="delete_category"
                      phx-value-id={category.id}
                      data-confirm="Are you sure you want to delete this category?"
                      class="text-gray-400 hover:text-red-600 transition-colors"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                        >
                        </path>
                      </svg>
                    </button>
                  </div>
                </div>

                <p class="text-gray-600 text-sm mb-4 line-clamp-2">{category.description}</p>

                <div class="flex items-center justify-between">
                  <span class="text-xs text-gray-400">
                    Created {format_datetime(category.inserted_at)}
                  </span>
                  <a
                    href={"/dashboard/categories/#{category.id}"}
                    class="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                  >
                    View Details
                  </a>
                </div>
              </div>
            </div>
          <% end %>
        </div>
        
    <!-- Empty State -->
        <%= if Enum.empty?(@categories) do %>
          <div class="text-center py-16">
            <div class="w-24 h-24 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-6">
              <svg
                class="w-12 h-12 text-purple-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
                >
                </path>
              </svg>
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-2">No categories yet</h3>
            <p class="text-gray-600 mb-6">
              Create your first category to start organizing your emails
            </p>
            <button
              phx-click="show_create_modal"
              class="bg-purple-600 hover:bg-purple-700 text-white px-6 py-3 rounded-lg font-medium"
            >
              Create Your First Category
            </button>
          </div>
        <% end %>
      </div>
      
    <!-- Create/Edit Modal -->
      <%= if @show_modal do %>
        <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div class="mt-3">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-900">
                  {if @editing_category, do: "Edit Category", else: "Create New Category"}
                </h3>
                <button phx-click="hide_modal" class="text-gray-400 hover:text-gray-600">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M6 18L18 6M6 6l12 12"
                    >
                    </path>
                  </svg>
                </button>
              </div>

              <form phx-submit="save_category">
                <div class="space-y-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Name</label>
                    <input
                      type="text"
                      name="name"
                      value={@category_form["name"]}
                      required
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                      placeholder="Enter category name"
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                    <textarea
                      name="description"
                      rows="3"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                      placeholder="Enter category description"
                    >{@category_form["description"]}</textarea>
                  </div>
                </div>

                <div class="flex items-center justify-end space-x-3 mt-6">
                  <button
                    type="button"
                    phx-click="hide_modal"
                    class="px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-medium transition-colors"
                  >
                    {if @editing_category, do: "Update Category", else: "Create Category"}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      <% end %>
    </div>
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
