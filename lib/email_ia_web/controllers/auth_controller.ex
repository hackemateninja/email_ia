defmodule EmailIaWeb.AuthController do
  alias EmailIa.GoogleAccounts.GoogleAccount
  alias EmailIa.{Repo, User}
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
        # Validate required fields
        if is_nil(info.email) or info.email == "" do
          IO.puts("ERROR: Email is missing from OAuth response")

          conn
          |> put_flash(:error, "Email is required for authentication")
          |> redirect(to: ~p"/")
        else
          user_params = %{
            email: info.email,
            name: info.name,
            image: info.image,
            provider: "google",
            provider_uid: auth.uid
          }

          case find_or_create_user(user_params) do
            {:ok, user} ->
              IO.puts("User created/found successfully: #{inspect(user)}")

              token_expiry =
                auth.credentials.expires_at
                |> DateTime.from_unix!(:second)
                |> DateTime.truncate(:second)

              google_account_params = %{
                email: info.email,
                access_token: auth.credentials.token,
                refresh_token: auth.credentials.refresh_token,
                token_expiry: token_expiry,
                user_id: user.id,
                provider_uid: auth.uid
              }

              case find_or_create_google_account(google_account_params) do
                {:ok, _google_account} ->
                  conn
                  |> put_session(:current_user, user)
                  |> put_flash(:info, "Successfully authenticated with Google!")
                  |> redirect(to: ~p"/dashboard")

                {:error, _changeset} ->
                  conn
                  |> clear_session()
                  |> put_flash(
                    :error,
                    "Authenticated but failed to save Gmail access. You may need to reconnect."
                  )
                  |> redirect(to: ~p"/")
              end

            {:error, changeset} ->
              IO.puts("Error creating user: #{inspect(changeset.errors)}")

              conn
              |> clear_session()
              |> put_flash(
                :error,
                "Error creating user account: #{inspect(changeset)}"
              )
              |> redirect(to: ~p"/")
          end
        end
    end
  end

  defp find_or_create_user(params) do
    case Repo.get_by(User, email: params.email) do
      nil ->
        %User{}
        |> User.changeset(params)
        |> Repo.insert()

      user ->
        user
        |> User.changeset(params)
        |> Repo.update()
    end
  end

  defp find_or_create_google_account(params) do
    case Repo.get_by(GoogleAccount, user_id: params.user_id) do
      nil ->
        %GoogleAccount{}
        |> GoogleAccount.changeset(params)
        |> Repo.insert()

      google_account ->
        google_account
        |> GoogleAccount.changeset(params)
        |> Repo.update()
    end
  end
end
