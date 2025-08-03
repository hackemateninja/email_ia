defmodule EmailIa.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :image, :string
    field :provider, :string
    field :provider_uid, :string

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
    # In a real app, you'd query the database
    # For now, we'll return nil to simulate a new user
    nil
  end

  defp create_user(attrs) do
    # In a real app, you'd insert into the database
    # For now, we'll just return the attrs as a user struct
    user = %__MODULE__{
      id: :crypto.strong_rand_bytes(16) |> Base.encode16(),
      email: attrs.email,
      name: attrs.name,
      image: attrs.image,
      provider: attrs.provider,
      provider_uid: attrs.provider_uid,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    {:ok, user}
  end
end
