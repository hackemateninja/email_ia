defmodule EmailIaWeb.EmailLive do
  use EmailIaWeb, :live_view
  alias EmailIa.Repo
  alias EmailIa.Emails.Email
  alias EmailIa.GoogleAccounts.GoogleAccount

  def render(assigns) do
    ~H"""
    <.dashboard_container>
      <.dashboard_header_with_back_actions
        name={@email.subject}
        description={@email.from}
        first_icon="hero-pencil"
        second_icon="hero-trash"
        first_button_text="Edit"
        second_button_text="Delete"
        first_button_action={JS.push("edit_email")}
        second_button_action={JS.push("delete_email")}
        navigate={~p"/dashboard/emails"}
        back_text="Emails"
      />
      
    <!-- Email Content -->
      <div class="bg-white p-2">
        <!-- Email Header -->
        <div class=" pb-2 mb-2">
          <h2 class="text-lg  text-gray-900 mb-4">{@email.subject}</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
            <div>
              <span class="font-light text-xs text-gray-700">From:</span>
              <span class="text-gray-900 ml-2">{@email.from}</span>
            </div>
            <div>
              <span class="font-light text-xs text-gray-700">To:</span>
              <span class="text-gray-900 ml-2">{@email.to}</span>
            </div>
            <div>
              <span class="font-light text-xs text-gray-700">Date:</span>
              <span class="text-gray-900 ml-2">{format_datetime(@email.inserted_at)}</span>
            </div>
            <div>
              <span class="font-light text-xs text-gray-700">Message ID:</span>
              <span class="text-gray-900 ml-2 font-mono text-xs">{@email.message_id}</span>
            </div>
          </div>
          <%= if @email.category do %>
            <div class="mt-4">
              <span class="font-light text-xs text-gray-700">Category:</span>
              <span class="inline-flex items-center  p-1 text-xs  font-light bg-[#0f62fe] text-white ml-2">
                {@email.category.name}
              </span>
            </div>
          <% end %>
        </div>
        
    <!-- AI Summary -->
        <%= if @email.ai_summary do %>
          <div class="bg-blue-50 border border-blue-200  p-2 mb-2">
            <div class="flex items-start space-x-4">
              <div class="flex-shrink-0">
                <div class="w-10 h-10 bg-blue-100  flex items-center justify-center">
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
        <div class="bg-gray-50  p-2 mb-2">
          <h3 class="font-semibold text-gray-900 mb-2">Email Snippet</h3>
          <p class="text-gray-700">{@email.snippet}</p>
        </div>
        
    <!-- Original Email Content -->
        <div class="mb-2">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900">Original Email Content</h3>
          </div>
          <div class="bg-gray-50  p-4 border">
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
            <div class="bg-yellow-50 border border-yellow-200  p-4">
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
          <div class="bg-gray-50 border border-gray-200  p-4">
            <h4 class="font-semibold text-gray-900 mb-2">Import Information</h4>
            <div class="space-y-2 text-sm">
              <div>
                <span class="font-light text-gray-700">Imported:</span>
                <span class="text-gray-900 ml-2">{format_datetime(@email.imported_at)}</span>
              </div>
              <div>
                <span class="font-light text-gray-700">Status:</span>
                <span class={[
                  "ml-2 px-2 py-1  text-xs font-light",
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
    </.dashboard_container>
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
