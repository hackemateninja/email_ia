defmodule EmailIaWeb.CurrentRoute do
  use Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     assign(socket, :current_route, current_route(socket.view, socket.assigns.live_action))}
  end

  defp current_route(EmailIaWeb.DashboardLive, _live_action), do: :dashboard
  defp current_route(EmailIaWeb.EmailsLive, _live_action), do: :emails
  defp current_route(EmailIaWeb.EmailLive, _live_action), do: :emails
  defp current_route(EmailIaWeb.Dashboard.Category.CategoriesLive, _live_action), do: :categories
  defp current_route(EmailIaWeb.Dashboard.Category.CategoryLive, _live_action), do: :categories
  defp current_route(EmailIaWeb.AccountsLive, _), do: :accounts
  defp current_route(_, _), do: :unknown
end
