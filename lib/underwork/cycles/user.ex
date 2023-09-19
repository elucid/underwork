defmodule Underwork.Cycles.User do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
  end

  def new(params) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(sale, params) do
    sale
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
