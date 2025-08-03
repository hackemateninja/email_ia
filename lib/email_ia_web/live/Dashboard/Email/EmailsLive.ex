defmodule EmailIaWeb.EmailsLive do
  use EmailIaWeb, :live_view
  import Ecto.Query
  alias EmailIa.Repo
  alias EmailIa.Emails.Email
  alias EmailIa.GoogleAccounts.GoogleAccount
  alias EmailIa.Categories.Category

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-200 p-6">
      <div class="max-w-7xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-4xl font-bold text-gray-900 mb-2">Emails</h1>
              <p class="text-gray-600">Manage and organize your email collection</p>
            </div>
            <div class="flex items-center space-x-3">
              <button
                phx-click="refresh_emails"
                class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium flex items-center space-x-2 transition-colors"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                  >
                  </path>
                </svg>
                <span>Refresh</span>
              </button>
            </div>
          </div>
        </div>
        
    <!-- Tabs -->
        <div class="bg-white rounded-xl shadow-lg mb-6">
          <div class="border-b border-gray-200">
            <nav class="flex space-x-8 px-6" aria-label="Tabs">
              <button
                phx-click="switch_tab"
                phx-value-tab="archived"
                class={[
                  "py-4 px-1 border-b-2 font-medium text-sm transition-colors",
                  if(@active_tab == "archived",
                    do: "border-purple-500 text-purple-600",
                    else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  )
                ]}
              >
                <div class="flex items-center space-x-2">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-14 0h14"
                    >
                    </path>
                  </svg>
                  <span>Archived Emails</span>
                  <span class="bg-gray-100 text-gray-900 py-0.5 px-2.5 rounded-full text-xs font-medium">
                    {@archived_count}
                  </span>
                </div>
              </button>
              <button
                phx-click="switch_tab"
                phx-value-tab="gmail"
                class={[
                  "py-4 px-1 border-b-2 font-medium text-sm transition-colors",
                  if(@active_tab == "gmail",
                    do: "border-purple-500 text-purple-600",
                    else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  )
                ]}
              >
                <div class="flex items-center space-x-2">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                    >
                    </path>
                  </svg>
                  <span>Gmail Integration</span>
                  <span class="bg-yellow-100 text-yellow-800 py-0.5 px-2.5 rounded-full text-xs font-medium">
                    Coming Soon
                  </span>
                </div>
              </button>
            </nav>
          </div>
          
    <!-- Tab Content -->
          <div class="p-6">
            <%= if @active_tab == "archived" do %>
              <!-- Archived Emails Tab -->
              <div>
                <!-- Search and Filters -->
                <div class="flex items-center justify-between mb-6">
                  <div class="flex items-center space-x-4 flex-1">
                    <div class="relative flex-1 max-w-md">
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
                        value={@search}
                        class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                      />
                    </div>
                    <select
                      phx-change="filter_by_category"
                      value={@selected_category}
                      class="border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                    >
                      <option value="">All Categories</option>
                      <%= for category <- @categories do %>
                        <option value={category.id}>{category.name}</option>
                      <% end %>
                    </select>
                    <select
                      phx-change="sort_emails"
                      value={@sort_by}
                      class="border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                    >
                      <option value="inserted_at">Date</option>
                      <option value="subject">Subject</option>
                      <option value="from">Sender</option>
                    </select>
                  </div>
                  <div class="flex items-center space-x-3">
                    <div class="flex items-center space-x-2">
                      <input
                        type="checkbox"
                        id="select-all"
                        phx-click="toggle_select_all"
                        checked={@select_all}
                        class="rounded border-gray-300 text-purple-600 focus:ring-purple-500"
                      />
                      <label for="select-all" class="text-sm text-gray-700">Select All</label>
                    </div>
                    <%= if length(@selected_emails) > 0 do %>
                      <button
                        phx-click="bulk_delete"
                        data-confirm="Are you sure you want to delete the selected emails? This action cannot be undone."
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
                        <span>Delete Selected ({length(@selected_emails)})</span>
                      </button>
                    <% end %>
                  </div>
                </div>
                
    <!-- Emails List -->
                <div class="space-y-4">
                  <%= for email <- @emails do %>
                    <div class={[
                      "bg-white border rounded-lg p-4 transition-all duration-200",
                      if(email.id in @selected_emails,
                        do: "ring-2 ring-purple-500 border-purple-300",
                        else: "border-gray-200 hover:border-gray-300"
                      )
                    ]}>
                      <div class="flex items-start space-x-4">
                        <div class="flex items-center pt-1">
                          <input
                            type="checkbox"
                            id={"email-#{email.id}"}
                            phx-click="toggle_email_selection"
                            phx-value-id={email.id}
                            checked={email.id in @selected_emails}
                            class="rounded border-gray-300 text-purple-600 focus:ring-purple-500"
                          />
                        </div>
                        <div class="flex-1 min-w-0">
                          <div class="flex items-start justify-between mb-2">
                            <div class="flex-1 min-w-0">
                              <h3 class="text-lg font-medium text-gray-900 truncate">
                                {email.subject}
                              </h3>
                              <p class="text-sm text-gray-500">From: {email.from} • To: {email.to}</p>
                            </div>
                            <div class="flex items-center space-x-2 ml-4">
                              <span class="text-xs text-gray-400">
                                {format_datetime(email.inserted_at)}
                              </span>
                              <%= if email.category do %>
                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                                  {email.category.name}
                                </span>
                              <% end %>
                            </div>
                          </div>

                          <p class="text-sm text-gray-600 mb-3 line-clamp-2">{email.snippet}</p>
                          
    <!-- AI Summary -->
                          <%= if email.ai_summary do %>
                            <div class="bg-blue-50 border border-blue-200 rounded-lg p-3 mb-3">
                              <div class="flex items-start space-x-2">
                                <svg
                                  class="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0"
                                  fill="none"
                                  stroke="currentColor"
                                  viewBox="0 0 24 24"
                                >
                                  <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
                                  >
                                  </path>
                                </svg>
                                <div class="flex-1">
                                  <h4 class="text-sm font-medium text-blue-900 mb-1">AI Summary</h4>
                                  <p class="text-sm text-blue-800">{email.ai_summary}</p>
                                </div>
                              </div>
                            </div>
                          <% end %>

                          <div class="flex items-center justify-between">
                            <div class="flex items-center space-x-4">
                              <button
                                phx-click="view_email"
                                phx-value-id={email.id}
                                class="text-purple-600 hover:text-purple-800 text-sm font-medium flex items-center space-x-1"
                              >
                                <svg
                                  class="w-4 h-4"
                                  fill="none"
                                  stroke="currentColor"
                                  viewBox="0 0 24 24"
                                >
                                  <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                                  >
                                  </path>
                                  <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                                  >
                                  </path>
                                </svg>
                                <span>View Details</span>
                              </button>
                              <button
                                phx-click="view_original"
                                phx-value-id={email.id}
                                class="text-gray-600 hover:text-gray-800 text-sm font-medium flex items-center space-x-1"
                              >
                                <svg
                                  class="w-4 h-4"
                                  fill="none"
                                  stroke="currentColor"
                                  viewBox="0 0 24 24"
                                >
                                  <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                                  >
                                  </path>
                                </svg>
                                <span>View Original</span>
                              </button>
                            </div>
                            <button
                              phx-click="delete_email"
                              phx-value-id={email.id}
                              data-confirm="Are you sure you want to delete this email?"
                              class="text-red-600 hover:text-red-800 text-sm font-medium"
                            >
                              Delete
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  <% end %>

                  <%= if Enum.empty?(@emails) do %>
                    <div class="text-center py-16">
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
                      <h3 class="text-xl font-semibold text-gray-900 mb-2">
                        No archived emails found
                      </h3>
                      <p class="text-gray-600">Archived emails will appear here once you have them</p>
                    </div>
                  <% end %>
                </div>
              </div>
            <% else %>
              <!-- Gmail Integration Tab -->
              <div class="text-center py-16">
                <div class="w-24 h-24 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-6">
                  <svg
                    class="w-12 h-12 text-yellow-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
                    >
                    </path>
                  </svg>
                </div>
                <h3 class="text-xl font-semibold text-gray-900 mb-2">
                  Gmail Integration Coming Soon
                </h3>
                <p class="text-gray-600 mb-6">
                  We're working on integrating with Gmail to automatically fetch and process your emails.
                </p>
                <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 max-w-md mx-auto">
                  <h4 class="font-medium text-yellow-900 mb-2">What's coming:</h4>
                  <ul class="text-sm text-yellow-800 space-y-1">
                    <li>• Automatic email fetching from Gmail</li>
                    <li>• Real-time email processing</li>
                    <li>• AI-powered email categorization</li>
                    <li>• Smart email filtering and search</li>
                  </ul>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
      
    <!-- Email Detail Modal -->
      <%= if @show_email_modal do %>
        <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div class="relative top-10 mx-auto p-5 border w-full max-w-4xl shadow-lg rounded-md bg-white">
            <div class="mt-3">
              <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-semibold text-gray-900">Email Details</h3>
                <button phx-click="hide_email_modal" class="text-gray-400 hover:text-gray-600">
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

              <%= if @selected_email do %>
                <div class="space-y-6">
                  <!-- Email Header -->
                  <div class="border-b border-gray-200 pb-4">
                    <h2 class="text-2xl font-bold text-gray-900 mb-2">{@selected_email.subject}</h2>
                    <div class="flex items-center space-x-4 text-sm text-gray-600">
                      <span><strong>From:</strong> {@selected_email.from}</span>
                      <span><strong>To:</strong> {@selected_email.to}</span>
                      <span>
                        <strong>Date:</strong> {format_datetime(@selected_email.inserted_at)}
                      </span>
                    </div>
                  </div>
                  
    <!-- AI Summary -->
                  <%= if @selected_email.ai_summary do %>
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
                            d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
                          >
                          </path>
                        </svg>
                        <div class="flex-1">
                          <h4 class="text-lg font-semibold text-blue-900 mb-2">AI Summary</h4>
                          <p class="text-blue-800">{@selected_email.ai_summary}</p>
                        </div>
                      </div>
                    </div>
                  <% end %>
                  
    <!-- Email Content -->
                  <div class="bg-gray-50 rounded-lg p-4">
                    <h4 class="font-semibold text-gray-900 mb-2">Email Content</h4>
                    <div class="prose max-w-none">
                      <p class="text-gray-700 whitespace-pre-wrap">{@selected_email.original_body}</p>
                    </div>
                  </div>
                  
    <!-- Actions -->
                  <div class="flex items-center justify-end space-x-3 pt-4 border-t border-gray-200">
                    <button
                      phx-click="view_original"
                      phx-value-id={@selected_email.id}
                      class="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
                    >
                      View Original Email
                    </button>
                    <button
                      phx-click="hide_email_modal"
                      class="px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
                    >
                      Close
                    </button>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>
      
    <!-- Original Email Modal -->
      <%= if @show_original_modal do %>
        <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div class="relative top-10 mx-auto p-5 border w-full max-w-6xl shadow-lg rounded-md bg-white">
            <div class="mt-3">
              <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-semibold text-gray-900">Original Email</h3>
                <button phx-click="hide_original_modal" class="text-gray-400 hover:text-gray-600">
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

              <%= if @selected_email do %>
                <div class="bg-gray-50 rounded-lg p-6 max-h-96 overflow-y-auto">
                  <div class="prose max-w-none">
                    <div class="mb-4 p-4 bg-white rounded border">
                      <div class="text-sm text-gray-600 mb-2">
                        <strong>From:</strong> {@selected_email.from}<br />
                        <strong>To:</strong> {@selected_email.to}<br />
                        <strong>Subject:</strong> {@selected_email.subject}<br />
                        <strong>Date:</strong> {format_datetime(@selected_email.inserted_at)}
                      </div>
                    </div>
                    <div class="bg-white p-4 rounded border">
                      <div class="whitespace-pre-wrap text-gray-800">
                        {@selected_email.original_body}
                      </div>
                    </div>
                  </div>
                </div>

                <div class="flex items-center justify-end space-x-3 pt-4 border-t border-gray-200">
                  <button
                    phx-click="hide_original_modal"
                    class="px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
                  >
                    Close
                  </button>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    emails = fetch_archived_emails(current_user.id)

    socket =
      assign(socket,
        active_tab: "archived",
        emails: emails,
        archived_count: length(emails),
        categories: fetch_categories(current_user.id),
        search: "",
        selected_category: "",
        sort_by: "inserted_at",
        select_all: false,
        selected_emails: [],
        show_email_modal: false,
        show_original_modal: false,
        selected_email: nil
      )

    {:ok, socket}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, active_tab: tab)}
  end

  def handle_event("search_emails", %{"value" => search}, socket) do
    socket = assign(socket, search: search)

    emails =
      filter_and_sort_emails(
        socket.assigns.emails,
        search,
        socket.assigns.selected_category,
        socket.assigns.sort_by
      )

    {:noreply, assign(socket, emails: emails, archived_count: length(emails))}
  end

  def handle_event("filter_by_category", %{"value" => category_id}, socket) do
    socket = assign(socket, selected_category: category_id)

    emails =
      filter_and_sort_emails(
        socket.assigns.emails,
        socket.assigns.search,
        category_id,
        socket.assigns.sort_by
      )

    {:noreply, assign(socket, emails: emails, archived_count: length(emails))}
  end

  def handle_event("sort_emails", %{"value" => sort_by}, socket) do
    socket = assign(socket, sort_by: sort_by)

    emails =
      filter_and_sort_emails(
        socket.assigns.emails,
        socket.assigns.search,
        socket.assigns.selected_category,
        sort_by
      )

    {:noreply, assign(socket, emails: emails, archived_count: length(emails))}
  end

  def handle_event("toggle_select_all", _params, socket) do
    select_all = !socket.assigns.select_all
    selected_emails = if select_all, do: Enum.map(socket.assigns.emails, & &1.id), else: []

    socket = assign(socket, select_all: select_all, selected_emails: selected_emails)
    {:noreply, socket}
  end

  def handle_event("toggle_email_selection", %{"id" => id}, socket) do
    selected_emails =
      if id in socket.assigns.selected_emails do
        List.delete(socket.assigns.selected_emails, id)
      else
        [id | socket.assigns.selected_emails]
      end

    select_all = length(selected_emails) == length(socket.assigns.emails)
    socket = assign(socket, selected_emails: selected_emails, select_all: select_all)
    {:noreply, socket}
  end

  def handle_event("bulk_delete", _params, socket) do
    current_user = socket.assigns.current_user

    case bulk_delete_emails(socket.assigns.selected_emails) do
      {:ok, _} ->
        emails = fetch_archived_emails(current_user.id)

        socket =
          assign(socket,
            emails: emails,
            archived_count: length(emails),
            selected_emails: [],
            select_all: false
          )

        {:noreply, put_flash(socket, :info, "Selected emails deleted successfully!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete emails. Please try again.")}
    end
  end

  def handle_event("delete_email", %{"id" => id}, socket) do
    current_user = socket.assigns.current_user

    case delete_email(id) do
      {:ok, _} ->
        emails = fetch_archived_emails(current_user.id)
        socket = assign(socket, emails: emails, archived_count: length(emails))
        {:noreply, put_flash(socket, :info, "Email deleted successfully!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete email. Please try again.")}
    end
  end

  def handle_event("view_email", %{"id" => id}, socket) do
    email = Repo.get(Email, id)

    socket =
      assign(socket,
        show_email_modal: true,
        selected_email: email
      )

    {:noreply, socket}
  end

  def handle_event("view_original", %{"id" => id}, socket) do
    email = Repo.get(Email, id)

    socket =
      assign(socket,
        show_original_modal: true,
        selected_email: email
      )

    {:noreply, socket}
  end

  def handle_event("hide_email_modal", _params, socket) do
    socket = assign(socket, show_email_modal: false, selected_email: nil)
    {:noreply, socket}
  end

  def handle_event("hide_original_modal", _params, socket) do
    socket = assign(socket, show_original_modal: false, selected_email: nil)
    {:noreply, socket}
  end

  def handle_event("refresh_emails", _params, socket) do
    current_user = socket.assigns.current_user
    emails = fetch_archived_emails(current_user.id)
    socket = assign(socket, emails: emails, archived_count: length(emails))
    {:noreply, put_flash(socket, :info, "Emails refreshed successfully!")}
  end

  defp fetch_archived_emails(user_id) do
    Repo.all(
      from(e in Email,
        join: ga in GoogleAccount,
        on: e.google_account_id == ga.id,
        left_join: c in Category,
        on: e.category_id == c.id,
        where: ga.user_id == ^user_id and e.archived == true,
        preload: [category: c],
        order_by: [desc: e.inserted_at]
      )
    )
  end

  defp fetch_categories(user_id) do
    Repo.all(from(c in Category, where: c.user_id == ^user_id, order_by: c.name))
  end

  defp filter_and_sort_emails(emails, search, category_id, sort_by) do
    emails
    |> Enum.filter(fn email ->
      search_match =
        search == "" or
          String.contains?(String.downcase(email.subject), String.downcase(search)) or
          String.contains?(String.downcase(email.from), String.downcase(search)) or
          String.contains?(String.downcase(email.snippet), String.downcase(search))

      category_match =
        category_id == "" or
          (email.category_id && to_string(email.category_id) == category_id)

      search_match and category_match
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

  defp bulk_delete_emails(email_ids) do
    Repo.delete_all(from(e in Email, where: e.id in ^email_ids))
    {:ok, length(email_ids)}
  end

  defp delete_email(email_id) do
    email = Repo.get(Email, email_id)
    if email, do: Repo.delete(email), else: {:error, :not_found}
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y at %I:%M %p")
  end
end
