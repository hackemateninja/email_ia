defmodule EmailIa.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :message_id, :string
      add :subject, :string
      add :from, :string
      add :to, :string
      add :snippet, :string
      add :ai_summary, :text
      add :original_body, :text
      add :unsubscribe_link, :string
      add :imported_at, :utc_datetime
      add :archived, :boolean, default: false, null: false
      add :google_account_id, references(:google_accounts, on_delete: :nothing, type: :binary_id)
      add :category_id, references(:categories, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:emails, [:google_account_id])
    create index(:emails, [:category_id])
  end
end
