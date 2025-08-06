defmodule EmailIa.Repo do
  use Ecto.Repo,
    otp_app: :email_ia,
    adapter: Ecto.Adapters.SQLite3
end
