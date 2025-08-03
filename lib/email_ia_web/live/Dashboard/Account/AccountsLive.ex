defmodule EmailIaWeb.AccountsLive do
  use EmailIaWeb, :live_view
  import Ecto.Query
  alias EmailIa.Repo
  alias EmailIa.User
  alias EmailIa.GoogleAccounts.GoogleAccount
  alias EmailIa.Emails.Email

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-200 p-6">
      <div class="max-w-7xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-4xl font-bold text-gray-900 mb-2">Account Management</h1>
              <p class="text-gray-600">Manage your account and connected Google accounts</p>
            </div>
            <button
              phx-click="show_add_google_modal"
              class="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium flex items-center space-x-2 transition-colors"
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
              <span>Add Google Account</span>
            </button>
          </div>
        </div>
        
    <!-- User Account Section -->
        <div class="bg-white rounded-xl shadow-lg p-8 mb-8">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-semibold text-gray-900">Your Account</h2>
            <button
              phx-click="edit_user_account"
              class="text-purple-600 hover:text-purple-800 text-sm font-medium flex items-center space-x-1"
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
              <span>Edit Profile</span>
            </button>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <!-- User Info -->
            <div class="space-y-4">
              <div class="flex items-center space-x-4">
                <div class="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center">
                  <%= if @current_user.image do %>
                    <img src={@current_user.image} alt="Profile" class="w-16 h-16 rounded-full" />
                  <% else %>
                    <svg
                      class="w-8 h-8 text-purple-600"
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
                  <% end %>
                </div>
                <div>
                  <h3 class="text-xl font-semibold text-gray-900">{@current_user.name}</h3>
                  <p class="text-gray-600">{@current_user.email}</p>
                </div>
              </div>

              <div class="space-y-3">
                <div class="flex justify-between items-center py-2 border-b border-gray-100">
                  <span class="text-gray-600">Provider</span>
                  <span class="font-medium text-gray-900 capitalize">{@current_user.provider}</span>
                </div>
                <div class="flex justify-between items-center py-2 border-b border-gray-100">
                  <span class="text-gray-600">Member Since</span>
                  <span class="font-medium text-gray-900">
                    {format_datetime(@current_user.inserted_at)}
                  </span>
                </div>
                <div class="flex justify-between items-center py-2 border-b border-gray-100">
                  <span class="text-gray-600">Last Updated</span>
                  <span class="font-medium text-gray-900">
                    {format_datetime(@current_user.updated_at)}
                  </span>
                </div>
              </div>
            </div>
            
    <!-- Account Stats -->
            <div class="space-y-4">
              <h4 class="font-semibold text-gray-900 mb-4">Account Statistics</h4>
              <div class="grid grid-cols-2 gap-4">
                <div class="bg-blue-50 rounded-lg p-4">
                  <div class="flex items-center space-x-3">
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
                    <div>
                      <p class="text-sm text-gray-600">Total Emails</p>
                      <p class="text-xl font-bold text-gray-900">{@total_emails}</p>
                    </div>
                  </div>
                </div>

                <div class="bg-green-50 rounded-lg p-4">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                      <svg
                        class="w-4 h-4 text-green-600"
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
                      <p class="text-sm text-gray-600">Google Accounts</p>
                      <p class="text-xl font-bold text-gray-900">{@google_accounts_count}</p>
                    </div>
                  </div>
                </div>

                <div class="bg-purple-50 rounded-lg p-4">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                      <svg
                        class="w-4 h-4 text-purple-600"
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
                      <p class="text-sm text-gray-600">Categories</p>
                      <p class="text-xl font-bold text-gray-900">{@categories_count}</p>
                    </div>
                  </div>
                </div>

                <div class="bg-orange-50 rounded-lg p-4">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center">
                      <svg
                        class="w-4 h-4 text-orange-600"
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
                    <div>
                      <p class="text-sm text-gray-600">Archived</p>
                      <p class="text-xl font-bold text-gray-900">{@archived_emails_count}</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Google Accounts Section -->
        <div class="bg-white rounded-xl shadow-lg p-8">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-semibold text-gray-900">Connected Google Accounts</h2>
            <button
              phx-click="show_add_google_modal"
              class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg font-medium flex items-center space-x-2 transition-colors"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                >
                </path>
              </svg>
              <span>Add Account</span>
            </button>
          </div>

          <div class="space-y-4">
            <%= for account <- @google_accounts do %>
              <div class="border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow">
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-4">
                    <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
                      <svg
                        class="w-6 h-6 text-red-600"
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
                      <h3 class="text-lg font-semibold text-gray-900">{account.email}</h3>
                      <div class="flex items-center space-x-4 text-sm text-gray-500">
                        <span>Connected {format_datetime(account.inserted_at)}</span>
                        <span>•</span>
                        <span>{account.email_count} emails</span>
                        <%= if is_token_expired(account) do %>
                          <span>•</span>
                          <span class="text-red-600 font-medium">Token Expired</span>
                        <% end %>
                      </div>
                    </div>
                  </div>

                  <div class="flex items-center space-x-3">
                    <%= if is_token_expired(account) do %>
                      <button
                        phx-click="refresh_token"
                        phx-value-id={account.id}
                        class="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1 rounded text-sm font-medium transition-colors"
                      >
                        Refresh Token
                      </button>
                    <% end %>
                    <button
                      phx-click="disconnect_account"
                      phx-value-id={account.id}
                      data-confirm="Are you sure you want to disconnect this Google account? This will remove all associated emails."
                      class="text-red-600 hover:text-red-800 text-sm font-medium"
                    >
                      Disconnect
                    </button>
                  </div>
                </div>
                
    <!-- Account Details -->
                <div class="mt-4 pt-4 border-t border-gray-100">
                  <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                    <div>
                      <span class="text-gray-600">Token Expires:</span>
                      <span class="ml-2 font-medium text-gray-900">
                        {format_datetime(account.token_expiry)}
                      </span>
                    </div>
                    <div>
                      <span class="text-gray-600">Status:</span>
                      <span class={[
                        "ml-2 px-2 py-1 rounded-full text-xs font-medium",
                        if(is_token_expired(account),
                          do: "bg-red-100 text-red-800",
                          else: "bg-green-100 text-green-800"
                        )
                      ]}>
                        {if is_token_expired(account), do: "Expired", else: "Active"}
                      </span>
                    </div>
                    <div>
                      <span class="text-gray-600">Last Sync:</span>
                      <span class="ml-2 font-medium text-gray-900">
                        {format_datetime(account.updated_at)}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>

            <%= if Enum.empty?(@google_accounts) do %>
              <div class="text-center py-12">
                <div class="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
                  <svg
                    class="w-12 h-12 text-gray-400"
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
                <h3 class="text-xl font-semibold text-gray-900 mb-2">No Google accounts connected</h3>
                <p class="text-gray-600 mb-6">
                  Connect your Google accounts to start importing emails
                </p>
                <button
                  phx-click="show_add_google_modal"
                  class="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium"
                >
                  Connect Your First Google Account
                </button>
              </div>
            <% end %>
          </div>
        </div>
      </div>
      
    <!-- Add Google Account Modal -->
      <%= if @show_add_google_modal do %>
        <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div class="mt-3">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-900">Add Google Account</h3>
                <button phx-click="hide_add_google_modal" class="text-gray-400 hover:text-gray-600">
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

              <div class="space-y-4">
                <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <div class="flex items-start space-x-3">
                    <svg
                      class="w-6 h-6 text-blue-600 mt-1 flex-shrink-0"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                      >
                      </path>
                    </svg>
                    <div>
                      <h4 class="font-medium text-blue-900 mb-1">How it works</h4>
                      <p class="text-sm text-blue-800">
                        You'll be redirected to Google to authorize access to your emails.
                        We'll only access emails you choose to import.
                      </p>
                    </div>
                  </div>
                </div>

                <div class="space-y-3">
                  <div class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg">
                    <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                      <svg
                        class="w-4 h-4 text-green-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M5 13l4 4L19 7"
                        >
                        </path>
                      </svg>
                    </div>
                    <div>
                      <p class="font-medium text-gray-900">Secure OAuth Flow</p>
                      <p class="text-sm text-gray-600">Uses Google's official OAuth 2.0</p>
                    </div>
                  </div>

                  <div class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg">
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
                          d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                        >
                        </path>
                      </svg>
                    </div>
                    <div>
                      <p class="font-medium text-gray-900">Read-Only Access</p>
                      <p class="text-sm text-gray-600">We only read your emails, never modify</p>
                    </div>
                  </div>

                  <div class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg">
                    <div class="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                      <svg
                        class="w-4 h-4 text-purple-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                        >
                        </path>
                      </svg>
                    </div>
                    <div>
                      <p class="font-medium text-gray-900">Revoke Anytime</p>
                      <p class="text-sm text-gray-600">You can disconnect accounts anytime</p>
                    </div>
                  </div>
                </div>

                <div class="flex items-center justify-end space-x-3 pt-4 border-t border-gray-200">
                  <button
                    type="button"
                    phx-click="hide_add_google_modal"
                    class="px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
                  >
                    Cancel
                  </button>
                  <a
                    href="/auth/google"
                    class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg font-medium transition-colors"
                  >
                    Connect Google Account
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    # Fetch account statistics
    account_stats = fetch_account_stats(current_user.id)

    socket =
      assign(socket,
        google_accounts: fetch_google_accounts(current_user.id),
        total_emails: account_stats.total_emails,
        google_accounts_count: account_stats.google_accounts_count,
        categories_count: account_stats.categories_count,
        archived_emails_count: account_stats.archived_emails_count,
        show_add_google_modal: false
      )

    {:ok, socket}
  end

  def handle_event("show_add_google_modal", _params, socket) do
    socket = assign(socket, show_add_google_modal: true)
    {:noreply, socket}
  end

  def handle_event("hide_add_google_modal", _params, socket) do
    socket = assign(socket, show_add_google_modal: false)
    {:noreply, socket}
  end

  def handle_event("edit_user_account", _params, socket) do
    # For now, just show a flash message
    {:noreply, put_flash(socket, :info, "User profile editing will be available soon!")}
  end

  def handle_event("disconnect_account", %{"id" => id}, socket) do
    current_user = socket.assigns.current_user
    account = Repo.get(GoogleAccount, id)

    if account && account.user_id == current_user.id do
      case delete_google_account(account) do
        {:ok, _} ->
          account_stats = fetch_account_stats(current_user.id)

          socket =
            assign(socket,
              google_accounts: fetch_google_accounts(current_user.id),
              total_emails: account_stats.total_emails,
              google_accounts_count: account_stats.google_accounts_count,
              categories_count: account_stats.categories_count,
              archived_emails_count: account_stats.archived_emails_count
            )

          {:noreply, put_flash(socket, :info, "Google account disconnected successfully!")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to disconnect account. Please try again.")}
      end
    else
      {:noreply, put_flash(socket, :error, "Account not found or access denied.")}
    end
  end

  def handle_event("refresh_token", %{"id" => id}, socket) do
    # For now, just show a flash message
    {:noreply, put_flash(socket, :info, "Token refresh functionality will be available soon!")}
  end

  defp fetch_google_accounts(user_id) do
    Repo.all(
      from(ga in GoogleAccount,
        where: ga.user_id == ^user_id,
        left_join: e in Email,
        on: e.google_account_id == ga.id,
        group_by: [
          ga.id,
          ga.email,
          ga.access_token,
          ga.refresh_token,
          ga.token_expiry,
          ga.inserted_at,
          ga.updated_at
        ],
        select:
          {ga.id, ga.email, ga.access_token, ga.refresh_token, ga.token_expiry, ga.inserted_at,
           ga.updated_at, count(e.id)},
        order_by: [desc: ga.inserted_at]
      )
    )
    |> Enum.map(fn {id, email, access_token, refresh_token, token_expiry, inserted_at, updated_at,
                    email_count} ->
      %{
        id: id,
        email: email,
        access_token: access_token,
        refresh_token: refresh_token,
        token_expiry: token_expiry,
        inserted_at: inserted_at,
        updated_at: updated_at,
        email_count: email_count
      }
    end)
  end

  defp fetch_account_stats(user_id) do
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

    # Get Google accounts count
    google_accounts_count =
      Repo.aggregate(
        from(ga in GoogleAccount, where: ga.user_id == ^user_id),
        :count,
        :id
      )

    # Get categories count
    categories_count =
      Repo.aggregate(
        from(c in EmailIa.Categories.Category, where: c.user_id == ^user_id),
        :count,
        :id
      )

    # Get archived emails count
    archived_emails_count =
      Repo.aggregate(
        from(e in Email,
          join: ga in GoogleAccount,
          on: e.google_account_id == ga.id,
          where: ga.user_id == ^user_id and e.archived == true
        ),
        :count,
        :id
      )

    %{
      total_emails: total_emails,
      google_accounts_count: google_accounts_count,
      categories_count: categories_count,
      archived_emails_count: archived_emails_count
    }
  end

  defp delete_google_account(account) do
    Repo.delete(account)
  end

  defp is_token_expired(account) do
    case account.token_expiry do
      nil -> true
      expiry -> DateTime.compare(DateTime.utc_now(), expiry) == :gt
    end
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y at %I:%M %p")
  end
end
