defmodule EmailIa.Repo.Migrations.CreateDemos do
  use Ecto.Migration

  def change do
    create table(:demos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:demos, [:user_id])
  end
end
