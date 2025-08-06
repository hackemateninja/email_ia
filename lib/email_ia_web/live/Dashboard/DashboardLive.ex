defmodule EmailIaWeb.DashboardLive do
  use EmailIaWeb, :live_view
  import Ecto.Query
  alias EmailIa.Repo
  alias EmailIa.Categories.Category
  alias EmailIa.GoogleAccounts.GoogleAccount
  alias EmailIa.Emails.Email

  @impl true
  def render(assigns) do
    ~H"""
    <.dashboard_container>
      <!-- Header -->
      <.dashboard_header
        title={"Welcome back, #{@current_user.name}!"}
        description="Here's an overview of your email management"
      />

    <!-- Stats Cards -->
      <.dashboard_four_cols>
        <!-- Total Emails -->
        <.dashboard_stat_card title="Total Emails" icon="hero-envelope" value={@total_emails} />
        <!-- Google Accounts -->
        <.dashboard_stat_card title="Google Accounts" icon="hero-user-plus" value={@total_accounts} />

    <!-- Categories -->
        <.dashboard_stat_card title="Categories" icon="hero-tag" value={@total_categories} />
        <!-- Archived Emails -->
        <.dashboard_stat_card title="Archived" icon="hero-archive-box" value={@archived_emails} />
      </.dashboard_four_cols>

    <!-- Recent Activity Section -->
      <.dashboard_two_cols>
        <!-- Recent Emails -->
        <.dashboard_list_card title="Recent Emails" link="/dashboard/emails">
          <.dashboard_list_email_item
            :for={email <- @recent_emails}
            subject={email.subject}
            from={email.from}
            inserted_at={email.inserted_at}
          />

          <.dashboard_list_empty
            :if={Enum.empty?(@recent_emails)}
            icon="hero-envelope"
            message="No emails yet"
          />
        </.dashboard_list_card>

    <!-- Categories Overview -->
        <.dashboard_list_card title="Categories" link="/dashboard/categories">
          <.dashboard_list_category_item
            :for={category <- @categories}
            name={category.name}
            description={category.description}
          />

          <.dashboard_list_empty
            :if={Enum.empty?(@categories)}
            icon="hero-tag"
            message="No categories yet"
          />
        </.dashboard_list_card>
      </.dashboard_two_cols>
    </.dashboard_container>
    """
  end

  @impl true
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
          group_by: [c.id],
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

end
