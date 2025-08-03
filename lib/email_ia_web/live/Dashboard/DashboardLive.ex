defmodule EmailIaWeb.DashboardLive do
  use EmailIaWeb, :live_view
  import Ecto.Query
  alias EmailIa.Repo
  alias EmailIa.User
  alias EmailIa.Categories.Category
  alias EmailIa.GoogleAccounts.GoogleAccount
  alias EmailIa.Emails.Email

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-200 p-6">
      <div class="max-w-7xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
          <h1 class="text-4xl font-bold text-gray-900 mb-2">Welcome back, {@current_user.name}!</h1>
          <p class="text-gray-600">Here's an overview of your email management</p>
        </div>
        
    <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <!-- Total Emails -->
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
          
    <!-- Google Accounts -->
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
                    d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                  >
                  </path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Google Accounts</p>
                <p class="text-2xl font-bold text-gray-900">{@total_accounts}</p>
              </div>
            </div>
          </div>
          
    <!-- Categories -->
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
                    d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
                  >
                  </path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Categories</p>
                <p class="text-2xl font-bold text-gray-900">{@total_categories}</p>
              </div>
            </div>
          </div>
          
    <!-- Archived Emails -->
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
                    d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-14 0h14"
                  >
                  </path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Archived</p>
                <p class="text-2xl font-bold text-gray-900">{@archived_emails}</p>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Recent Activity Section -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <!-- Recent Emails -->
          <div class="bg-white rounded-xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl font-semibold text-gray-900">Recent Emails</h3>
              <a
                href="/dashboard/emails"
                class="text-blue-600 hover:text-blue-800 text-sm font-medium"
              >
                View all
              </a>
            </div>
            <div class="space-y-4">
              <%= for email <- @recent_emails do %>
                <div class="flex items-start space-x-3 p-3 rounded-lg hover:bg-gray-50">
                  <div class="flex-shrink-0">
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
                  </div>
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 truncate">{email.subject}</p>
                    <p class="text-sm text-gray-500 truncate">From: {email.from}</p>
                    <p class="text-xs text-gray-400">{format_datetime(email.inserted_at)}</p>
                  </div>
                </div>
              <% end %>
              <%= if Enum.empty?(@recent_emails) do %>
                <div class="text-center py-8 text-gray-500">
                  <svg
                    class="w-12 h-12 mx-auto mb-4 text-gray-300"
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
                  <p>No emails yet</p>
                </div>
              <% end %>
            </div>
          </div>
          
    <!-- Categories Overview -->
          <div class="bg-white rounded-xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl font-semibold text-gray-900">Categories</h3>
              <a
                href="/dashboard/categories"
                class="text-blue-600 hover:text-blue-800 text-sm font-medium"
              >
                View all
              </a>
            </div>
            <div class="space-y-4">
              <%= for category <- @categories do %>
                <div class="flex items-center justify-between p-3 rounded-lg hover:bg-gray-50">
                  <div class="flex items-center space-x-3">
                    <div class="w-3 h-3 bg-purple-500 rounded-full"></div>
                    <div>
                      <p class="text-sm font-medium text-gray-900">{category.name}</p>
                      <p class="text-xs text-gray-500">{category.description}</p>
                    </div>
                  </div>
                  <span class="text-sm text-gray-500">{category.email_count} emails</span>
                </div>
              <% end %>
              <%= if Enum.empty?(@categories) do %>
                <div class="text-center py-8 text-gray-500">
                  <svg
                    class="w-12 h-12 mx-auto mb-4 text-gray-300"
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
                  <p>No categories yet</p>
                </div>
              <% end %>
            </div>
          </div>
        </div>
        
    <!-- Quick Actions -->
        <div class="mt-8 bg-white rounded-xl shadow-lg p-6">
          <h3 class="text-xl font-semibold text-gray-900 mb-6">Quick Actions</h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <a
              href="/dashboard/emails"
              class="flex items-center p-4 border border-gray-200 rounded-lg hover:border-blue-300 hover:bg-blue-50 transition-colors"
            >
              <div class="p-2 bg-blue-100 rounded-lg mr-3">
                <svg
                  class="w-5 h-5 text-blue-600"
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
              <div>
                <p class="font-medium text-gray-900">View Emails</p>
                <p class="text-sm text-gray-500">Browse all your emails</p>
              </div>
            </a>
            <a
              href="/dashboard/categories"
              class="flex items-center p-4 border border-gray-200 rounded-lg hover:border-purple-300 hover:bg-purple-50 transition-colors"
            >
              <div class="p-2 bg-purple-100 rounded-lg mr-3">
                <svg
                  class="w-5 h-5 text-purple-600"
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
                <p class="font-medium text-gray-900">Manage Categories</p>
                <p class="text-sm text-gray-500">Organize your emails</p>
              </div>
            </a>
            <a
              href="/dashboard/accounts"
              class="flex items-center p-4 border border-gray-200 rounded-lg hover:border-green-300 hover:bg-green-50 transition-colors"
            >
              <div class="p-2 bg-green-100 rounded-lg mr-3">
                <svg
                  class="w-5 h-5 text-green-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                  >
                  </path>
                </svg>
              </div>
              <div>
                <p class="font-medium text-gray-900">Google Accounts</p>
                <p class="text-sm text-gray-500">Manage connections</p>
              </div>
            </a>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    # Fetch dashboard data
    dashboard_data = fetch_dashboard_data(current_user.id)

    socket =
      assign(socket,
        total_emails: dashboard_data.total_emails,
        total_accounts: dashboard_data.total_accounts,
        total_categories: dashboard_data.total_categories,
        archived_emails: dashboard_data.archived_emails,
        recent_emails: dashboard_data.recent_emails,
        categories: dashboard_data.categories
      )

    {:ok, socket}
  end

  defp fetch_dashboard_data(user_id) do
    # Get total emails
    total_emails =
      Repo.aggregate(
        from(e in Email,
          join: ga in GoogleAccount,
          on: e.google_account_id == ga.id,
          where: ga.user_id == ^user_id
        ),
        :count,
        :id
      )

    # Get total Google accounts
    total_accounts =
      Repo.aggregate(
        from(ga in GoogleAccount, where: ga.user_id == ^user_id),
        :count,
        :id
      )

    # Get total categories
    total_categories =
      Repo.aggregate(
        from(c in Category, where: c.user_id == ^user_id),
        :count,
        :id
      )

    # Get archived emails count
    archived_emails =
      Repo.aggregate(
        from(e in Email,
          join: ga in GoogleAccount,
          on: e.google_account_id == ga.id,
          where: ga.user_id == ^user_id and e.archived == true
        ),
        :count,
        :id
      )

    # Get recent emails
    recent_emails =
      Repo.all(
        from(e in Email,
          join: ga in GoogleAccount,
          on: e.google_account_id == ga.id,
          where: ga.user_id == ^user_id,
          order_by: [desc: e.inserted_at],
          limit: 5
        )
      )

    # Get categories with email count
    categories =
      Repo.all(
        from(c in Category,
          where: c.user_id == ^user_id,
          left_join: e in Email,
          on: e.category_id == c.id,
          group_by: [c.id, c.name, c.description],
          select: {c.name, c.description, count(e.id)}
        )
      )
      |> Enum.map(fn {name, description, count} ->
        %{name: name, description: description, email_count: count}
      end)

    %{
      total_emails: total_emails,
      total_accounts: total_accounts,
      total_categories: total_categories,
      archived_emails: archived_emails,
      recent_emails: recent_emails,
      categories: categories
    }
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y at %I:%M %p")
  end
end
