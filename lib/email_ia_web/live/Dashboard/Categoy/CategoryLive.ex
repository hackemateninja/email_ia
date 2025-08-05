defmodule EmailIaWeb.Dashboard.Category.CategoryLive do
  use EmailIaWeb, :live_view
  alias EmailIa.Categories.Category
  alias EmailIa.Categories
  alias EmailIa.Emails.Email
  import Ecto.Query
  alias EmailIa.Repo

  def render(assigns) do
    ~H"""
    <.dashboard_container>
      <!-- Header -->
      <.dashboard_header_with_back_actions
        name={@category.name}
        description={@category.description}
        first_icon="hero-pencil"
        second_icon="hero-trash"
        first_button_text="Edit"
        second_button_text="Delete"
        first_button_action={JS.patch(~p"/dashboard/categories/#{@category.id}/show/edit")}
        second_button_action={JS.push("delete", value: %{id: @category.id})}
        navigate={~p"/dashboard/categories"}
        back_text="Categories"
      />

    <!-- Category Stats -->
      <.dashboard_four_cols>
        <.dashboard_stat_card title="Total Emails" icon="hero-envelope" value={@total_emails} />
        <.dashboard_stat_card
          title="Created"
          icon="hero-calendar"
          value={format_datetime(@category.inserted_at)}
        />
        <.dashboard_stat_card
          title="Last Updated"
          icon="hero-clock"
          value={format_datetime(@category.updated_at)}
        />
        <.dashboard_stat_card title="Recent Activity" icon="hero-clock" value={@recent_emails_count} />
      </.dashboard_four_cols>

    <!-- Emails Section -->

      <div class="flex items-center justify-between mb-2">
        <h3 class="text-lg font-light text-gray-900">Emails in this Category</h3>
      </div>

      <div class="space-y-2">
        <%= for email <- @emails do %>
          <.dashboard_email_card
            subject={email.subject}
            from={email.from}
            snippet={email.snippet}
            inserted_at={email.inserted_at}
            id={email.id}
            to={email.to}
          />
        <% end %>

        <.dashboard_empty_page
          :if={Enum.empty?(@emails)}
          title="No emails found"
          description="There are no emails in this category yet"
          icon="hero-envelope"
        />
      </div>
    </.dashboard_container>

    <.modal
      :if={@live_action in [:edit]}
      id="category-modal"
      show
      on_cancel={JS.patch(~p"/dashboard/categories/#{@category.id}")}
    >
      <.live_component
        module={EmailIaWeb.Dashboard.Category.FormComponent}
        id={@category.id || :new}
        title={@page_title}
        action={@live_action}
        category={@category}
        patch={~p"/dashboard/categories/#{@category.id}"}
      />
    </.modal>
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


  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:category, Categories.get_category!(id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Categories.get_category!(id)
    {:ok, _} = Categories.delete_category(category)

    {:noreply, push_navigate(socket, to: "/dashboard/categories")}
  end

  defp page_title(:show), do: "Show Category"
  defp page_title(:edit), do: "Edit Category"

  defp fetch_category_emails(category_id) do
    Repo.all(
      from(e in Email,
        where: e.category_id == ^category_id,
        order_by: [desc: e.inserted_at]
      )
    )
  end


  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y")
  end
end
