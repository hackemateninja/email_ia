defmodule EmailIa.EmailsTest do
  use EmailIa.DataCase

  alias EmailIa.Emails

  describe "emails" do
    alias EmailIa.Emails.Email

    import EmailIa.EmailsFixtures

    @invalid_attrs %{snippet: nil, to: nil, from: nil, message_id: nil, subject: nil, ai_summary: nil, original_body: nil, unsubscribe_link: nil, imported_at: nil, archived: nil}

    test "list_emails/0 returns all emails" do
      email = email_fixture()
      assert Emails.list_emails() == [email]
    end

    test "get_email!/1 returns the email with given id" do
      email = email_fixture()
      assert Emails.get_email!(email.id) == email
    end

    test "create_email/1 with valid data creates a email" do
      valid_attrs = %{snippet: "some snippet", to: "some to", from: "some from", message_id: "some message_id", subject: "some subject", ai_summary: "some ai_summary", original_body: "some original_body", unsubscribe_link: "some unsubscribe_link", imported_at: ~U[2025-08-02 09:18:00Z], archived: true}

      assert {:ok, %Email{} = email} = Emails.create_email(valid_attrs)
      assert email.snippet == "some snippet"
      assert email.to == "some to"
      assert email.from == "some from"
      assert email.message_id == "some message_id"
      assert email.subject == "some subject"
      assert email.ai_summary == "some ai_summary"
      assert email.original_body == "some original_body"
      assert email.unsubscribe_link == "some unsubscribe_link"
      assert email.imported_at == ~U[2025-08-02 09:18:00Z]
      assert email.archived == true
    end

    test "create_email/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Emails.create_email(@invalid_attrs)
    end

    test "update_email/2 with valid data updates the email" do
      email = email_fixture()
      update_attrs = %{snippet: "some updated snippet", to: "some updated to", from: "some updated from", message_id: "some updated message_id", subject: "some updated subject", ai_summary: "some updated ai_summary", original_body: "some updated original_body", unsubscribe_link: "some updated unsubscribe_link", imported_at: ~U[2025-08-03 09:18:00Z], archived: false}

      assert {:ok, %Email{} = email} = Emails.update_email(email, update_attrs)
      assert email.snippet == "some updated snippet"
      assert email.to == "some updated to"
      assert email.from == "some updated from"
      assert email.message_id == "some updated message_id"
      assert email.subject == "some updated subject"
      assert email.ai_summary == "some updated ai_summary"
      assert email.original_body == "some updated original_body"
      assert email.unsubscribe_link == "some updated unsubscribe_link"
      assert email.imported_at == ~U[2025-08-03 09:18:00Z]
      assert email.archived == false
    end

    test "update_email/2 with invalid data returns error changeset" do
      email = email_fixture()
      assert {:error, %Ecto.Changeset{}} = Emails.update_email(email, @invalid_attrs)
      assert email == Emails.get_email!(email.id)
    end

    test "delete_email/1 deletes the email" do
      email = email_fixture()
      assert {:ok, %Email{}} = Emails.delete_email(email)
      assert_raise Ecto.NoResultsError, fn -> Emails.get_email!(email.id) end
    end

    test "change_email/1 returns a email changeset" do
      email = email_fixture()
      assert %Ecto.Changeset{} = Emails.change_email(email)
    end
  end
end
