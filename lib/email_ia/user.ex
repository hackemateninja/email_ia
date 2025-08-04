defmodule EmailIa.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :name, :string
    field :image, :string
    field :provider, :string
    field :provider_uid, :string
    has_many :categories, EmailIa.Categories.Category
    has_many :google_accounts, EmailIa.GoogleAccounts.GoogleAccount

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :image, :provider, :provider_uid])
    |> validate_required([:email, :name, :provider, :provider_uid])
    |> unique_constraint(:email)
    |> unique_constraint([:provider, :provider_uid])
  end
end
