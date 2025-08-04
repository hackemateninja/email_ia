defmodule EmailIa.GoogleAccounts.GoogleAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "google_accounts" do
    field :email, :string
    field :access_token, :string
    field :refresh_token, :string
    field :provider_uid, :string
    field :token_expiry, :utc_datetime

    belongs_to :user, EmailIa.User
    has_many :emails, EmailIa.Emails.Email

    timestamps(type: :utc_datetime)
  end

  @doc false
  @required_params ~w(provider_uid email access_token user_id)a
  @optional_params ~w(refresh_token token_expiry)a

  def changeset(account, attrs) do
    account
    |> cast(attrs, @required_params ++ @optional_params)
    |> validate_required(@required_params)
    |> unique_constraint(:user_id)
    |> unique_constraint(:provider_uid)
  end
end
