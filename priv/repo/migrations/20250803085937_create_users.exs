defmodule EmailIa.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :name, :string
      add :image, :string
      add :provider, :string, null: false
      add :provider_uid, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:provider, :provider_uid])
  end
end
