defmodule EmailIa.GmailService do
  @moduledoc """
  Service module for interacting with Gmail API to fetch emails.
  """

  def list_messages() do
    {:ok, token} = Goth.fetch(GmailGoth)
    conn = GoogleApi.Gmail.V1.Connection.new(token.token)

    {:ok, %{messages: %{message: msgs}}} =
      GoogleApi.Gmail.V1.Api.Users.gmail_users_messages_list(conn, "me", maxResults: 10)

    for %{"id" => msg_id} <- msgs do
      {:ok, msg_full} =
        GoogleApi.Gmail.V1.Api.Users.gmail_users_messages_get(conn, "me", msg_id)

      IO.inspect(msg_full.snippet, label: "#{msg_id} snippet")
    end
  end
end
