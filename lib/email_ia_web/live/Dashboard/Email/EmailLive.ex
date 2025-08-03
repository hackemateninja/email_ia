defmodule EmailIaWeb.EmailLive do
  use EmailIaWeb, :live_view
  import Ecto.Query
  alias EmailIa.Repo
  alias EmailIa.Emails.Email
  alias EmailIa.GoogleAccounts.GoogleAccount
  alias EmailIa.Categories.Category

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-200 p-6">
      <div class="max-w-4xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-4">
              <a
                href="/dashboard/emails"
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
                <span>Back to Emails</span>
              </a>
              <div class="w-px h-6 bg-gray-300"></div>
              <div>
                <h1 class="text-4xl font-bold text-gray-900 mb-2">Email Details</h1>
                <p class="text-gray-600">View and manage email information</p>
              </div>
            </div>
            <div class="flex items-center space-x-3">
              <button
                phx-click="toggle_archive"
                class={[
                  "px-4 py-2 rounded-lg font-medium flex items-center space-x-2 transition-colors",
                  if(@email.archived,
                    do: "bg-green-600 hover:bg-green-700 text-white",
                    else: "bg-orange-600 hover:bg-orange-700 text-white"
                  )
                ]}
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-14 0h14"
                  >
                  </path>
                </svg>
                <span>{if @email.archived, do: "Unarchive", else: "Archive"}</span>
              </button>
              <button
                phx-click="delete_email"
                data-confirm="Are you sure you want to delete this email? This action cannot be undone."
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
        
    <!-- Email Content -->
        <div class="bg-white rounded-xl shadow-lg p-8">
          <!-- Email Header -->
          <div class="border-b border-gray-200 pb-6 mb-6">
            <h2 class="text-3xl font-bold text-gray-900 mb-4">{@email.subject}</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
              <div>
                <span class="font-medium text-gray-700">From:</span>
                <span class="text-gray-900 ml-2">{@email.from}</span>
              </div>
              <div>
                <span class="font-medium text-gray-700">To:</span>
                <span class="text-gray-900 ml-2">{@email.to}</span>
              </div>
              <div>
                <span class="font-medium text-gray-700">Date:</span>
                <span class="text-gray-900 ml-2">{format_datetime(@email.inserted_at)}</span>
              </div>
              <div>
                <span class="font-medium text-gray-700">Message ID:</span>
                <span class="text-gray-900 ml-2 font-mono text-xs">{@email.message_id}</span>
              </div>
            </div>
            <%= if @email.category do %>
              <div class="mt-4">
                <span class="font-medium text-gray-700">Category:</span>
                <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-purple-100 text-purple-800 ml-2">
                  {@email.category.name}
                </span>
              </div>
            <% end %>
          </div>
          
    <!-- AI Summary -->
          <%= if @email.ai_summary do %>
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-6">
              <div class="flex items-start space-x-4">
                <div class="flex-shrink-0">
                  <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
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
                        d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
                      >
                      </path>
                    </svg>
                  </div>
                </div>
                <div class="flex-1">
                  <h3 class="text-lg font-semibold text-blue-900 mb-2">AI Summary</h3>
                  <p class="text-blue-800 leading-relaxed">{@email.ai_summary}</p>
                </div>
              </div>
            </div>
          <% end %>
          
    <!-- Email Snippet -->
          <div class="bg-gray-50 rounded-lg p-4 mb-6">
            <h3 class="font-semibold text-gray-900 mb-2">Email Snippet</h3>
            <p class="text-gray-700">{@email.snippet}</p>
          </div>
          
    <!-- Original Email Content -->
          <div class="mb-6">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-semibold text-gray-900">Original Email Content</h3>
              <button
                phx-click="toggle_content_view"
                class="text-purple-600 hover:text-purple-800 text-sm font-medium flex items-center space-x-1"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
                <span>{if @show_full_content, do: "Show Less", else: "Show More"}</span>
              </button>
            </div>
            <div class={[
              "bg-gray-50 rounded-lg p-4 border",
              if(@show_full_content, do: "", else: "max-h-64 overflow-hidden")
            ]}>
              <div class="prose max-w-none">
                <div class="whitespace-pre-wrap text-gray-800">{@email.original_body}</div>
              </div>
              <%= if not @show_full_content do %>
                <div class="absolute bottom-0 left-0 right-0 h-16 bg-gradient-to-t from-gray-50 to-transparent">
                </div>
              <% end %>
            </div>
          </div>
          
    <!-- Additional Information -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Unsubscribe Link -->
            <%= if @email.unsubscribe_link do %>
              <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                <h4 class="font-semibold text-yellow-900 mb-2">Unsubscribe Link</h4>
                <a
                  href={@email.unsubscribe_link}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-yellow-800 hover:text-yellow-900 text-sm break-all"
                >
                  {@email.unsubscribe_link}
                </a>
              </div>
            <% end %>
            
    <!-- Import Information -->
            <div class="bg-gray-50 border border-gray-200 rounded-lg p-4">
              <h4 class="font-semibold text-gray-900 mb-2">Import Information</h4>
              <div class="space-y-2 text-sm">
                <div>
                  <span class="font-medium text-gray-700">Imported:</span>
                  <span class="text-gray-900 ml-2">{format_datetime(@email.imported_at)}</span>
                </div>
                <div>
                  <span class="font-medium text-gray-700">Status:</span>
                  <span class={[
                    "ml-2 px-2 py-1 rounded-full text-xs font-medium",
                    if(@email.archived,
                      do: "bg-green-100 text-green-800",
                      else: "bg-blue-100 text-blue-800"
                    )
                  ]}>
                    {if @email.archived, do: "Archived", else: "Active"}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    current_user = socket.assigns.current_user
    email = Repo.get(Email, id)

    if email do
      # Verify the email belongs to the current user
      google_account = Repo.get(GoogleAccount, email.google_account_id)

      if google_account && google_account.user_id == current_user.id do
        # Preload category
        email = Repo.preload(email, :category)

        socket =
          assign(socket,
            email: email,
            show_full_content: false
          )

        {:ok, socket}
      else
        {:ok, push_navigate(socket, to: "/dashboard/emails")}
      end
    else
      {:ok, push_navigate(socket, to: "/dashboard/emails")}
    end
  end

  def handle_event("toggle_content_view", _params, socket) do
    show_full_content = !socket.assigns.show_full_content
    {:noreply, assign(socket, show_full_content: show_full_content)}
  end

  def handle_event("toggle_archive", _params, socket) do
    email = socket.assigns.email
    new_archived_status = !email.archived

    case update_email_archive_status(email, new_archived_status) do
      {:ok, updated_email} ->
        socket = assign(socket, email: updated_email)
        status_text = if new_archived_status, do: "archived", else: "unarchived"
        {:noreply, put_flash(socket, :info, "Email #{status_text} successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update email status. Please try again.")}
    end
  end

  def handle_event("delete_email", _params, socket) do
    email = socket.assigns.email

    case delete_email(email) do
      {:ok, _} ->
        {:noreply, push_navigate(socket, to: "/dashboard/emails")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete email. Please try again.")}
    end
  end

  defp update_email_archive_status(email, archived_status) do
    email
    |> Email.changeset(%{archived: archived_status})
    |> Repo.update()
  end

  defp delete_email(email) do
    Repo.delete(email)
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y at %I:%M %p")
  end
end
