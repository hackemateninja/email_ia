defmodule EmailIaWeb.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = get_session(conn, :current_user)

    if current_user do
      assign(conn, :current_user, current_user)
    else
      conn
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
