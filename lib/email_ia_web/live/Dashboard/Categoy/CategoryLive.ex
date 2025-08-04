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
        first_button_action={JS.push("edit_category")}
        second_button_action={JS.push("delete_category")}
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
