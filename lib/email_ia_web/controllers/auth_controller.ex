defmodule EmailIaWeb.AuthController do
  use EmailIaWeb, :controller
  plug Ueberauth

  def signin(conn, _params) do
    render(conn, :signin, layout: false)
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> configure_session(renew: true)
    |> put_flash(:info, "You have been logged out!")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    case fails do
      %Ueberauth.Failure{provider: :google, errors: errors} ->
        error_message = List.first(errors) |> Map.get(:message, "Unknown error")

        conn
        |> put_flash(:error, "Error authenticating with Google: #{error_message}")
        |> redirect(to: ~p"/")
    end
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case auth do
      %Ueberauth.Auth{provider: :google, info: info} ->
        user_params = %{
          email: info.email,
          name: info.name,
          image: info.image,
          provider: "google",
          provider_uid: auth.uid
        }

        case EmailIa.User.find_or_create_by_oauth(user_params) do
          {:ok, user} ->
            conn
            |> put_session(:current_user, user)
            |> put_flash(:info, "Successfully authenticated with Google!")
            |> redirect(to: ~p"/dashboard")
        end
    end
  end
end
