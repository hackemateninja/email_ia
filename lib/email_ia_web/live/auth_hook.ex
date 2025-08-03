defmodule EmailIaWeb.AuthHook do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, _params, session, socket) do
    case session["current_user"] do
      nil ->
        {:cont, socket |> assign(:current_user, nil) |> push_navigate(to: "/")}

      current_user ->
        {:cont, assign(socket, :current_user, current_user)}
    end
  end
end
