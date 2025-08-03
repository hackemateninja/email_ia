defmodule EmailIa.Emails.Email do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "emails" do
    field :snippet, :string
    field :to, :string
    field :from, :string
    field :message_id, :string
    field :subject, :string
    field :ai_summary, :string
    field :original_body, :string
    field :unsubscribe_link, :string
    field :imported_at, :utc_datetime
    field :archived, :boolean, default: false
    belongs_to :google_account, EmailIa.GoogleAccounts.GoogleAccount
    belongs_to :category, EmailIa.Categories.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [
      :message_id,
      :subject,
      :from,
      :to,
      :snippet,
      :ai_summary,
      :original_body,
      :unsubscribe_link,
      :imported_at,
      :archived
    ])
    |> validate_required([
      :message_id,
      :subject,
      :from,
      :to,
      :snippet,
      :ai_summary,
      :original_body,
      :unsubscribe_link,
      :imported_at,
      :archived
    ])
  end
end
