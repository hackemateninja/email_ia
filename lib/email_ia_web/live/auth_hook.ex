defmodule EmailIaWeb.AuthHook do
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    current_user = session["current_user"]
    {:cont, assign(socket, :current_user, current_user)}
  end
end
