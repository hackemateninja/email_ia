defmodule EmailIa.Demos.Demo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "demos" do
    field :name, :string
    field :description, :string
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(demo, attrs) do
    demo
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
