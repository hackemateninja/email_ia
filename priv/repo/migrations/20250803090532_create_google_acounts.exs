defmodule EmailIa.Repo.Migrations.CreateGoogleAcounts do
  use Ecto.Migration

  def change do
    create table(:google_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :access_token, :text
      add :refresh_token, :text
      add :token_expiry, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:google_acounts, [:user_id])
  end
end
