defmodule EmailIa.GoogleAccounts.GoogleAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "google_accounts" do
    field :email, :string
    field :access_token, :string
    field :refresh_token, :string
    field :token_expiry, :utc_datetime
    belongs_to :user, EmailIa.User
    has_many :emails, EmailIa.Emails.Email

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(google_account, attrs) do
    google_account
    |> cast(attrs, [:email, :access_token, :refresh_token, :token_expiry, :user_id])
    |> validate_required([:email, :access_token, :refresh_token, :user_id])
    |> validate_required([:token_expiry], message: "Token expiry is required")
  end
end
