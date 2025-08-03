defmodule EmailIa.GoogleAccounts.GoogleAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "google_acounts" do
    field :email, :string
    field :access_token, :string
    field :refresh_token, :string
    field :token_expiry, :utc_datetime
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(google_account, attrs) do
    google_account
    |> cast(attrs, [:email, :access_token, :refresh_token, :token_expiry])
    |> validate_required([:email, :access_token, :refresh_token, :token_expiry])
  end
end
