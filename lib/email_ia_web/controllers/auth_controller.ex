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
    IO.puts("=== OAuth Failure ===")
    IO.puts("Failure details: #{inspect(fails)}")

    case fails do
      %Ueberauth.Failure{provider: :google, errors: errors} ->
        error_message = List.first(errors) |> Map.get(:message, "Unknown error")

        conn
        |> put_flash(:error, "Error authenticating with Google: #{error_message}")
        |> redirect(to: ~p"/")
    end
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.puts("=== OAuth Success ===")
    IO.puts("Full auth object: #{inspect(auth)}")

    case auth do
      %Ueberauth.Auth{provider: :google, info: info} ->
        user_params = %{
          email: info.email,
          name: info.name,
          image: info.image,
          provider: "google",
          provider_uid: auth.uid
        }

        # Debug logging
        IO.puts("=== Auth Callback Debug ===")
        IO.puts("Auth info: #{inspect(info)}")
        IO.puts("Auth UID: #{auth.uid}")
        IO.puts("User params: #{inspect(user_params)}")

        # Validate required fields
        if is_nil(info.email) or info.email == "" do
          IO.puts("ERROR: Email is missing from OAuth response")

          conn
          |> put_flash(:error, "Email is required for authentication")
          |> redirect(to: ~p"/")
        else
          case EmailIa.User.find_or_create_by_oauth(user_params) do
            {:ok, user} ->
              IO.puts("User created/found successfully: #{inspect(user)}")

              conn
              |> put_session(:current_user, user)
              |> put_flash(:info, "Successfully authenticated with Google!")
              |> redirect(to: ~p"/dashboard")

            {:error, changeset} ->
              IO.puts("Error creating user: #{inspect(changeset.errors)}")

              conn
              |> put_flash(
                :error,
                "Error creating user account: #{format_changeset_errors(changeset)}"
              )
              |> redirect(to: ~p"/")
          end
        end
    end
  end

  defp format_changeset_errors(changeset) do
    changeset.errors
    |> Enum.map(fn {field, {message, _}} -> "#{field}: #{message}" end)
    |> Enum.join(", ")
  end
end
