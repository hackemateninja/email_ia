defmodule EmailIa.Repo do
  use Ecto.Repo,
    otp_app: :email_ia,
    adapter: Ecto.Adapters.Postgres
end
