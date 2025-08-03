defmodule EmailIa.GoogleAccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EmailIa.GoogleAccounts` context.
  """

  @doc """
  Generate a google_account.
  """
  def google_account_fixture(attrs \\ %{}) do
    {:ok, google_account} =
      attrs
      |> Enum.into(%{
        access_token: "some access_token",
        email: "some email",
        refresh_token: "some refresh_token",
        token_expiry: ~U[2025-08-02 09:05:00Z]
      })
      |> EmailIa.GoogleAccounts.create_google_account()

    google_account
  end
end
