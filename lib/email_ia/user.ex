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

  def find_or_create_by_oauth(attrs) do
    case find_by_provider_and_uid(attrs.provider, attrs.provider_uid) do
      nil -> create_user(attrs)
      user -> {:ok, user}
    end
  end

  defp find_by_provider_and_uid(provider, provider_uid) do
    EmailIa.Repo.get_by(__MODULE__, provider: provider, provider_uid: provider_uid)
  end

  defp create_user(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> EmailIa.Repo.insert()
  end
end
