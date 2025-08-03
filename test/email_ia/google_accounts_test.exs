defmodule EmailIa.GoogleAccountsTest do
  use EmailIa.DataCase

  alias EmailIa.GoogleAccounts

  describe "google_acounts" do
    alias EmailIa.GoogleAccounts.GoogleAccount

    import EmailIa.GoogleAccountsFixtures

    @invalid_attrs %{email: nil, access_token: nil, refresh_token: nil, token_expiry: nil}

    test "list_google_acounts/0 returns all google_acounts" do
      google_account = google_account_fixture()
      assert GoogleAccounts.list_google_acounts() == [google_account]
    end

    test "get_google_account!/1 returns the google_account with given id" do
      google_account = google_account_fixture()
      assert GoogleAccounts.get_google_account!(google_account.id) == google_account
    end

    test "create_google_account/1 with valid data creates a google_account" do
      valid_attrs = %{email: "some email", access_token: "some access_token", refresh_token: "some refresh_token", token_expiry: ~U[2025-08-02 09:05:00Z]}

      assert {:ok, %GoogleAccount{} = google_account} = GoogleAccounts.create_google_account(valid_attrs)
      assert google_account.email == "some email"
      assert google_account.access_token == "some access_token"
      assert google_account.refresh_token == "some refresh_token"
      assert google_account.token_expiry == ~U[2025-08-02 09:05:00Z]
    end

    test "create_google_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GoogleAccounts.create_google_account(@invalid_attrs)
    end

    test "update_google_account/2 with valid data updates the google_account" do
      google_account = google_account_fixture()
      update_attrs = %{email: "some updated email", access_token: "some updated access_token", refresh_token: "some updated refresh_token", token_expiry: ~U[2025-08-03 09:05:00Z]}

      assert {:ok, %GoogleAccount{} = google_account} = GoogleAccounts.update_google_account(google_account, update_attrs)
      assert google_account.email == "some updated email"
      assert google_account.access_token == "some updated access_token"
      assert google_account.refresh_token == "some updated refresh_token"
      assert google_account.token_expiry == ~U[2025-08-03 09:05:00Z]
    end

    test "update_google_account/2 with invalid data returns error changeset" do
      google_account = google_account_fixture()
      assert {:error, %Ecto.Changeset{}} = GoogleAccounts.update_google_account(google_account, @invalid_attrs)
      assert google_account == GoogleAccounts.get_google_account!(google_account.id)
    end

    test "delete_google_account/1 deletes the google_account" do
      google_account = google_account_fixture()
      assert {:ok, %GoogleAccount{}} = GoogleAccounts.delete_google_account(google_account)
      assert_raise Ecto.NoResultsError, fn -> GoogleAccounts.get_google_account!(google_account.id) end
    end

    test "change_google_account/1 returns a google_account changeset" do
      google_account = google_account_fixture()
      assert %Ecto.Changeset{} = GoogleAccounts.change_google_account(google_account)
    end
  end
end
