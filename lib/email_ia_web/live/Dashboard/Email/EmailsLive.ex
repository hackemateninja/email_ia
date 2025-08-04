defmodule EmailIaWeb.EmailsLive do
  use EmailIaWeb, :live_view
  import Ecto.Query
  alias EmailIa.Repo
  alias EmailIa.Emails.Email
  alias EmailIa.GoogleAccounts.GoogleAccount
  alias EmailIa.Categories.Category

  def render(assigns) do
    ~H"""
    <.dashboard_container>
      <!-- Header -->
      <.dashboard_header_with_action
        title="Emails"
        description="Manage and organize your email collection"
        button_text="Refresh"
        button_action={JS.push("refresh_emails")}
        icon="hero-arrow-path"
      />
      
    <!-- Tabs -->
      <div class="bg-white rounded-none shadow-lg mb-6">
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
                <.icon name="hero-envelope" class="w-5 h-5" />
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
                <.icon name="hero-envelope" class="w-5 h-5" />
                <span>Gmail Integration</span>
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
                      <.icon name="hero-magnifying-glass" class="h-5 w-5 text-gray-400" />
                    </div>
                    <input
                      type="text"
                      placeholder="Search emails..."
                      phx-keyup="search_emails"
                      phx-debounce="300"
                      value={@search}
                      class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                    />
                  </div>
                  <select
                    phx-change="filter_by_category"
                    value={@selected_category}
                    class="border border-gray-300 rounded-none px-3 py-2 focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  >
                    <option value="">All Categories</option>
                    <%= for category <- @categories do %>
                      <option value={category.id}>{category.name}</option>
                    <% end %>
                  </select>
                  <select
                    phx-change="sort_emails"
                    value={@sort_by}
                    class="border border-gray-300 rounded-none px-3 py-2 focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
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
                    <.dashboard_button
                      phx-click="bulk_delete"
                      data-confirm="Are you sure you want to delete the selected emails? This action cannot be undone."
                      kind={:danger}
                    >
                      <.icon name="hero-trash" class="w-4 h-4" />
                      <span>Delete Selected ({length(@selected_emails)})</span>
                    </.dashboard_button>
                  <% end %>
                </div>
              </div>
              
    <!-- Emails List -->
              <div class="space-y-4">
                <%= for email <- @emails do %>
                  <div class={[
                    "bg-white border rounded-none p-4 transition-all duration-200",
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
                              <.icon name="hero-sparkles" class="w-4 h-4 text-blue-500" />
                              <div class="flex-1">
                                <h4 class="text-sm font-medium text-blue-900 mb-1">AI Summary</h4>
                                <p class="text-sm text-blue-800">{email.ai_summary}</p>
                              </div>
                            </div>
                          </div>
                        <% end %>

                        <div class="flex items-center justify-end">
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
                      <.icon name="hero-envelope" class="w-12 h-12 text-gray-500" />
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
            <div>
              <!-- Gmail Account Status -->
              <div class="bg-white border border-gray-200 rounded-none p-6 mb-6">
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-4">
                    <div class="w-12 h-12 bg-red-100 rounded-none flex items-center justify-center">
                      <.icon name="hero-envelope" class="w-6 h-6 text-red-600" />
                    </div>
                    <div>
                      <h3 class="text-lg font-semibold text-gray-900">Gmail Account</h3>
                      <p class="text-sm text-gray-500">
                        {if @google_account,
                          do: @google_account.email,
                          else: "No Gmail account connected"}
                      </p>
                    </div>
                  </div>
                  <div class="text-right">
                    <div class="text-2xl font-bold text-gray-900">{@gmail_emails_count}</div>
                    <div class="text-sm text-gray-500">Gmail Emails</div>
                  </div>
                </div>
              </div>
              
    <!-- Fetch Emails Section -->
              <div class="bg-white border border-gray-200 rounded-none p-6 mb-6">
                <div class="flex items-center justify-between mb-4">
                  <div>
                    <h3 class="text-lg font-semibold text-gray-900">Fetch Gmail Emails</h3>
                    <p class="text-sm text-gray-600">Import emails from your Gmail account</p>
                  </div>
                  <.dashboard_button phx-click="fetch_gmail_emails">
                    <.icon name="hero-arrow-down-tray" class="w-4 h-4" />
                    <span>Fetch Emails</span>
                  </.dashboard_button>
                </div>

                <%= if @fetching_emails do %>
                  <div class="bg-blue-50 border border-blue-200 rounded-none p-4">
                    <div class="flex items-center space-x-3">
                      <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-600"></div>
                      <span class="text-blue-800">Fetching emails from Gmail...</span>
                    </div>
                  </div>
                <% end %>
              </div>
              
    <!-- Gmail Emails List -->
              <div class="bg-white border border-gray-200 rounded-none">
                <div class="p-6 border-b border-gray-200">
                  <div class="flex items-center justify-between">
                    <h3 class="text-lg font-semibold text-gray-900">Gmail Emails</h3>
                    <div class="flex items-center space-x-4">
                      <!-- Search -->
                      <div class="relative">
                        <input
                          type="text"
                          placeholder="Search Gmail emails..."
                          phx-keyup="search_gmail_emails"
                          phx-debounce="300"
                          class="w-64 px-4 py-2 border border-gray-300 rounded-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                        />
                        <.icon
                          name="hero-magnifying-glass"
                          class="absolute right-3 top-2.5 w-5 h-5 text-gray-400"
                        />
                      </div>
                      <!-- Sort -->
                      <select
                        phx-change="sort_gmail_emails"
                        class="px-4 py-2 border border-gray-300 rounded-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                      >
                        <option value="inserted_at">Date</option>
                        <option value="subject">Subject</option>
                        <option value="from">Sender</option>
                      </select>
                    </div>
                  </div>
                </div>

                <div class="divide-y divide-gray-200">
                  <%= if Enum.empty?(@gmail_emails) do %>
                    <.dashboard_empty_page
                      icon="hero-envelope"
                      title="No Gmail emails found"
                      description="Fetch emails from your Gmail account to get started"
                      button_text="Fetch Emails"
                      button_action={JS.push("fetch_gmail_emails")}
                    />
                  <% else %>
                    <%= for email <- @gmail_emails do %>
                      <div class="p-6 hover:bg-gray-50 transition-colors">
                        <div class="flex items-start justify-between">
                          <div class="flex-1 min-w-0">
                            <div class="flex items-center space-x-3 mb-2">
                              <h3 class="text-lg font-semibold text-gray-900 truncate">
                                {email.subject}
                              </h3>
                              <%= if email.archived do %>
                                <span class="px-2 py-1 bg-orange-100 text-orange-800 text-xs rounded-full">
                                  Archived
                                </span>
                              <% end %>
                            </div>
                            <p class="text-sm text-gray-600 mb-2">From: {email.from}</p>
                            <p class="text-sm text-gray-500 mb-3 line-clamp-2">{email.snippet}</p>
                            
    <!-- AI Summary -->
                            <%= if email.ai_summary && email.ai_summary != "" do %>
                              <div class="bg-blue-50 border border-blue-200 rounded-lg p-3 mb-3">
                                <div class="flex items-start space-x-2">
                                  <.icon name="hero-sparkles" class="w-4 h-4 text-blue-500" />
                                  <div class="flex-1">
                                    <h4 class="text-sm font-medium text-blue-900 mb-1">AI Summary</h4>
                                    <p class="text-sm text-blue-800">{email.ai_summary}</p>
                                  </div>
                                </div>
                              </div>
                            <% end %>

                            <div class="flex items-center space-x-4 text-xs text-gray-400">
                              <span>{format_datetime(email.inserted_at)}</span>
                              <span>•</span>
                              <span>To: {email.to}</span>
                              <%= if email.unsubscribe_link && email.unsubscribe_link != "" do %>
                                <span>•</span>
                                <a
                                  href={email.unsubscribe_link}
                                  class="text-blue-600 hover:text-blue-800"
                                >
                                  Unsubscribe
                                </a>
                              <% end %>
                            </div>
                          </div>
                          <div class="flex items-center space-x-2 ml-4">
                            <button
                              phx-click="view_gmail_email"
                              phx-value-id={email.id}
                              class="text-purple-600 hover:text-purple-800 text-sm font-medium"
                            >
                              View Details
                            </button>
                            <button
                              phx-click="toggle_gmail_archive"
                              phx-value-id={email.id}
                              class={[
                                "px-3 py-1 rounded text-sm font-medium transition-colors",
                                if(email.archived,
                                  do: "bg-green-100 text-green-800 hover:bg-green-200",
                                  else: "bg-gray-100 text-gray-800 hover:bg-gray-200"
                                )
                              ]}
                            >
                              {if email.archived, do: "Unarchive", else: "Archive"}
                            </button>
                          </div>
                        </div>
                      </div>
                    <% end %>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </.dashboard_container>
    """
  end

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    emails = fetch_archived_emails(current_user.id)
    google_account = get_user_google_account(current_user.id)
    gmail_emails = fetch_gmail_emails(current_user.id)

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
        selected_email: nil,
        google_account: google_account,
        gmail_emails: gmail_emails,
        gmail_emails_count: length(gmail_emails),
        fetching_emails: false,
        gmail_search: "",
        gmail_sort_by: "inserted_at"
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

  # Gmail Integration Functions
  defp get_user_google_account(user_id) do
    Repo.get_by(GoogleAccount, user_id: user_id)
  end

  defp fetch_gmail_emails(user_id) do
    Repo.all(
      from(e in Email,
        join: ga in GoogleAccount,
        on: e.google_account_id == ga.id,
        left_join: c in Category,
        on: e.category_id == c.id,
        where: ga.user_id == ^user_id,
        preload: [category: c],
        order_by: [desc: e.inserted_at]
      )
    )
  end

  # Gmail Event Handlers
  def handle_event("fetch_gmail_emails", _params, socket) do
    current_user = socket.assigns.current_user

    socket = assign(socket, fetching_emails: true)

    case EmailIa.GmailService.fetch_all_emails(current_user.id) do
      {:ok, count} ->
        # Refresh the Gmail emails data
        gmail_emails = fetch_gmail_emails(current_user.id)
        google_account = get_user_google_account(current_user.id)

        socket =
          socket
          |> assign(:gmail_emails, gmail_emails)
          |> assign(:gmail_emails_count, length(gmail_emails))
          |> assign(:google_account, google_account)
          |> assign(:fetching_emails, false)
          |> put_flash(:info, "Successfully fetched #{count} emails from Gmail!")

        {:noreply, socket}

      {:error, :no_google_account} ->
        socket = assign(socket, fetching_emails: false)

        {:noreply,
         put_flash(
           socket,
           :error,
           "No Google account found. Please connect your Gmail account first."
         )}

      {:error, reason} ->
        socket = assign(socket, fetching_emails: false)
        {:noreply, put_flash(socket, :error, "Failed to fetch emails: #{reason}")}
    end
  end

  def handle_event("search_gmail_emails", %{"value" => search}, socket) do
    socket = assign(socket, gmail_search: search)

    gmail_emails =
      filter_and_sort_gmail_emails(
        socket.assigns.gmail_emails,
        search,
        socket.assigns.gmail_sort_by
      )

    {:noreply, assign(socket, gmail_emails: gmail_emails)}
  end

  def handle_event("sort_gmail_emails", %{"value" => sort_by}, socket) do
    socket = assign(socket, gmail_sort_by: sort_by)

    gmail_emails =
      filter_and_sort_gmail_emails(
        socket.assigns.gmail_emails,
        socket.assigns.gmail_search,
        sort_by
      )

    {:noreply, assign(socket, gmail_emails: gmail_emails)}
  end

  def handle_event("view_gmail_email", %{"id" => email_id}, socket) do
    {:noreply, push_navigate(socket, to: "/dashboard/emails/#{email_id}")}
  end

  def handle_event("toggle_gmail_archive", %{"id" => email_id}, socket) do
    email = Repo.get(Email, email_id)

    if email do
      updated_email = Repo.update!(Ecto.Changeset.change(email, archived: !email.archived))

      # Refresh the Gmail emails list
      current_user = socket.assigns.current_user
      gmail_emails = fetch_gmail_emails(current_user.id)

      socket =
        socket
        |> assign(:gmail_emails, gmail_emails)
        |> put_flash(
          :info,
          "Email #{if updated_email.archived, do: "archived", else: "unarchived"} successfully!"
        )

      {:noreply, socket}
    else
      {:noreply, put_flash(socket, :error, "Email not found")}
    end
  end

  defp filter_and_sort_gmail_emails(emails, search, sort_by) do
    emails
    |> Enum.filter(fn email ->
      search == "" or
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
end
