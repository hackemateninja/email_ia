defmodule EmailIaWeb.CategoryLive do
  use EmailIaWeb, :live_view
  import Ecto.Query
  alias EmailIa.Repo
  alias EmailIa.Categories.Category
  alias EmailIa.Emails.Email
  alias EmailIa.GoogleAccounts.GoogleAccount

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-200 p-6">
      <div class="max-w-7xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-4">
              <a
                href="/dashboard/categories"
                class="text-purple-600 hover:text-purple-800 flex items-center space-x-1"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 19l-7-7 7-7"
                  >
                  </path>
                </svg>
                <span>Back to Categories</span>
              </a>
              <div class="w-px h-6 bg-gray-300"></div>
              <div>
                <h1 class="text-4xl font-bold text-gray-900 mb-2">{@category.name}</h1>
                <p class="text-gray-600">{@category.description}</p>
              </div>
            </div>
            <div class="flex items-center space-x-3">
              <button
                phx-click="edit_category"
                class="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg font-medium flex items-center space-x-2 transition-colors"
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
                <span>Edit</span>
              </button>
              <button
                phx-click="delete_category"
                data-confirm="Are you sure you want to delete this category? This action cannot be undone."
                class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg font-medium flex items-center space-x-2 transition-colors"
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
                <span>Delete</span>
              </button>
            </div>
          </div>
        </div>
        
    <!-- Category Stats -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-purple-500">
            <div class="flex items-center">
              <div class="p-3 rounded-full bg-purple-100">
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
                    d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                  >
                  </path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Total Emails</p>
                <p class="text-2xl font-bold text-gray-900">{@total_emails}</p>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-blue-500">
            <div class="flex items-center">
              <div class="p-3 rounded-full bg-blue-100">
                <svg
                  class="w-6 h-6 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                  >
                  </path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Created</p>
                <p class="text-2xl font-bold text-gray-900">
                  {format_datetime(@category.inserted_at)}
                </p>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-green-500">
            <div class="flex items-center">
              <div class="p-3 rounded-full bg-green-100">
                <svg
                  class="w-6 h-6 text-green-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                  >
                  </path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Last Updated</p>
                <p class="text-2xl font-bold text-gray-900">
                  {format_datetime(@category.updated_at)}
                </p>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-orange-500">
            <div class="flex items-center">
              <div class="p-3 rounded-full bg-orange-100">
                <svg
                  class="w-6 h-6 text-orange-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13 10V3L4 14h7v7l9-11h-7z"
                  >
                  </path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Recent Activity</p>
                <p class="text-2xl font-bold text-gray-900">{@recent_emails_count}</p>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Emails Section -->
        <div class="bg-white rounded-xl shadow-lg p-6">
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-xl font-semibold text-gray-900">Emails in this Category</h3>
            <div class="flex items-center space-x-4">
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
                  placeholder="Search emails..."
                  phx-keyup="search_emails"
                  phx-debounce="300"
                  value={@email_search}
                  class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                />
              </div>
              <select
                phx-change="sort_emails"
                value={@email_sort_by}
                class="border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
              >
                <option value="inserted_at">Date</option>
                <option value="subject">Subject</option>
                <option value="from">Sender</option>
              </select>
            </div>
          </div>

          <div class="space-y-4">
            <%= for email <- @emails do %>
              <div class="border border-gray-200 rounded-lg p-4 hover:bg-gray-50 transition-colors">
                <div class="flex items-start justify-between">
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center space-x-3 mb-2">
                      <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                        <svg
                          class="w-4 h-4 text-blue-600"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                          >
                          </path>
                        </svg>
                      </div>
                      <div class="flex-1 min-w-0">
                        <h4 class="text-sm font-medium text-gray-900 truncate">{email.subject}</h4>
                        <p class="text-sm text-gray-500">From: {email.from}</p>
                      </div>
                    </div>
                    <p class="text-sm text-gray-600 line-clamp-2">{email.snippet}</p>
                    <div class="flex items-center space-x-4 mt-2 text-xs text-gray-400">
                      <span>{format_datetime(email.inserted_at)}</span>
                      <span>•</span>
                      <span>To: {email.to}</span>
                      <%= if email.archived do %>
                        <span>•</span>
                        <span class="text-orange-600">Archived</span>
                      <% end %>
                    </div>
                  </div>
                  <div class="flex items-center space-x-2 ml-4">
                    <a
                      href={"/dashboard/emails/#{email.id}"}
                      class="text-purple-600 hover:text-purple-800 text-sm font-medium"
                    >
                      View
                    </a>
                  </div>
                </div>
              </div>
            <% end %>

            <%= if Enum.empty?(@emails) do %>
              <div class="text-center py-12">
                <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <svg
                    class="w-8 h-8 text-gray-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                    >
                    </path>
                  </svg>
                </div>
                <h3 class="text-lg font-medium text-gray-900 mb-2">No emails in this category</h3>
                <p class="text-gray-600">Emails assigned to this category will appear here</p>
              </div>
            <% end %>
          </div>
        </div>
      </div>
      
    <!-- Edit Modal -->
      <%= if @show_edit_modal do %>
        <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div class="mt-3">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-900">Edit Category</h3>
                <button phx-click="hide_edit_modal" class="text-gray-400 hover:text-gray-600">
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

              <form phx-submit="update_category">
                <div class="space-y-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Name</label>
                    <input
                      type="text"
                      name="name"
                      value={@category_form["name"]}
                      required
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                    <textarea
                      name="description"
                      rows="3"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                    >{@category_form["description"]}</textarea>
                  </div>
                </div>

                <div class="flex items-center justify-end space-x-3 mt-6">
                  <button
                    type="button"
                    phx-click="hide_edit_modal"
                    class="px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-medium transition-colors"
                  >
                    Update Category
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

  def mount(%{"id" => id}, _session, socket) do
    current_user = socket.assigns.current_user
    category = Repo.get(Category, id)

    if category && category.user_id == current_user.id do
      emails = fetch_category_emails(category.id)
      total_emails = length(emails)

      recent_emails_count =
        Enum.count(emails, fn email ->
          DateTime.diff(DateTime.utc_now(), email.inserted_at, :day) <= 7
        end)

      socket =
        assign(socket,
          category: category,
          emails: emails,
          total_emails: total_emails,
          recent_emails_count: recent_emails_count,
          email_search: "",
          email_sort_by: "inserted_at",
          show_edit_modal: false,
          category_form: %{"name" => category.name, "description" => category.description}
        )

      {:ok, socket}
    else
      {:ok, push_navigate(socket, to: "/dashboard/categories")}
    end
  end

  def handle_event("search_emails", %{"value" => search}, socket) do
    socket = assign(socket, email_search: search)
    emails = filter_and_sort_emails(socket.assigns.emails, search, socket.assigns.email_sort_by)
    {:noreply, assign(socket, emails: emails)}
  end

  def handle_event("sort_emails", %{"value" => sort_by}, socket) do
    socket = assign(socket, email_sort_by: sort_by)
    emails = filter_and_sort_emails(socket.assigns.emails, socket.assigns.email_search, sort_by)
    {:noreply, assign(socket, emails: emails)}
  end

  def handle_event("edit_category", _params, socket) do
    socket = assign(socket, show_edit_modal: true)
    {:noreply, socket}
  end

  def handle_event("hide_edit_modal", _params, socket) do
    socket = assign(socket, show_edit_modal: false)
    {:noreply, socket}
  end

  def handle_event("update_category", %{"name" => name, "description" => description}, socket) do
    category = socket.assigns.category
    params = %{name: name, description: description}

    case update_category(category, params) do
      {:ok, updated_category} ->
        socket =
          assign(socket,
            show_edit_modal: false,
            category: updated_category,
            category_form: %{
              "name" => updated_category.name,
              "description" => updated_category.description
            }
          )

        {:noreply, put_flash(socket, :info, "Category updated successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update category. Please try again.")}
    end
  end

  def handle_event("delete_category", _params, socket) do
    category = socket.assigns.category

    case delete_category(category) do
      {:ok, _category} ->
        {:noreply, push_navigate(socket, to: "/dashboard/categories")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete category. Please try again.")}
    end
  end

  defp fetch_category_emails(category_id) do
    Repo.all(
      from(e in Email,
        where: e.category_id == ^category_id,
        order_by: [desc: e.inserted_at]
      )
    )
  end

  defp filter_and_sort_emails(emails, search, sort_by) do
    emails
    |> Enum.filter(fn email ->
      String.contains?(String.downcase(email.subject), String.downcase(search)) or
        String.contains?(String.downcase(email.from), String.downcase(search)) or
        String.contains?(String.downcase(email.snippet), String.downcase(search))
    end)
    |> Enum.sort_by(
      fn email ->
        case sort_by do
          "subject" -> email.subject
          "from" -> email.from
          "inserted_at" -> email.inserted_at
          _ -> email.inserted_at
        end
      end,
      case sort_by do
        "inserted_at" -> :desc
        _ -> :asc
      end
    )
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
