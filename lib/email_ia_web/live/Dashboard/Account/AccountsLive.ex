defmodule EmailIaWeb.AccountsLive do
  use EmailIaWeb, :live_view
  import Ecto.Query
  alias EmailIa.Repo
  alias EmailIa.GoogleAccounts.GoogleAccount
  alias EmailIa.Emails.Email

  def render(assigns) do
    ~H"""
    <.dashboard_container>
      <.dashboard_header
        title="Account Management"
        description="Manage your account and connected Google accounts"
      />

      <div class="bg-white p-2 mb-2">
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-lg font-light text-gray-900">Your Account</h2>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div class="space-y-4">
            <div class="flex items-center space-x-4">
              <div class="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center">
                <%= if @current_user.image do %>
                  <img src={@current_user.image} alt="Profile" class="w-16 h-16 rounded-full" />
                <% else %>
                  <.icon name="hero-user" class="w-16 h-16" />
                <% end %>
              </div>
              <div>
                <h3 class="text-sm font-light text-gray-900">{@current_user.name}</h3>
                <p class="text-xs text-gray-600">{@current_user.email}</p>
              </div>
            </div>

            <div class="space-y-2">
              <.dashboard_account_summary_data title="Provider" value={@current_user.provider} />
              <.dashboard_account_summary_data
                title="Member Since"
                value={format_datetime(@current_user.inserted_at)}
              />

              <.dashboard_account_summary_data
                title="Last Updated"
                value={format_datetime(@current_user.updated_at)}
              />
            </div>
          </div>

          <div class="space-y-2">
            <h4 class="font-semibold text-gray-900 mb-2">Account Statistics</h4>
            <div class="grid grid-cols-2 gap-2">
              <.dashboard_stat_card title="Total Emails" value={@total_emails} icon="hero-envelope" />

              <.dashboard_stat_card
                title="Google Accounts"
                value={@google_accounts_count}
                icon="hero-user"
              />

              <.dashboard_stat_card title="Categories" value={@categories_count} icon="hero-tag" />

              <.dashboard_stat_card
                title="Archived"
                value={@archived_emails_count}
                icon="hero-archive-box"
              />
            </div>
          </div>
        </div>
      </div>
    </.dashboard_container>
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
