defmodule EmailIa.EmailsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EmailIa.Emails` context.
  """

  @doc """
  Generate a email.
  """
  def email_fixture(attrs \\ %{}) do
    {:ok, email} =
      attrs
      |> Enum.into(%{
        ai_summary: "some ai_summary",
        archived: true,
        from: "some from",
        imported_at: ~U[2025-08-02 09:18:00Z],
        message_id: "some message_id",
        original_body: "some original_body",
        snippet: "some snippet",
        subject: "some subject",
        to: "some to",
        unsubscribe_link: "some unsubscribe_link"
      })
      |> EmailIa.Emails.create_email()

    email
  end
end
