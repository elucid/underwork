defmodule Underwork.Cycles.Cycle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cycles" do
    field :accomplish, :string
    field :energy, :integer
    field :hazards, :string
    field :morale, :integer
    field :started, :string

    belongs_to :session, Underwork.Cycles.Session

    timestamps()
  end

  @doc false
  def changeset(cycle, attrs) do
    cycle
    |> cast(attrs, [:accomplish, :started, :hazards, :energy, :morale, :session_id])
    |> validate_required([:accomplish, :started, :hazards, :energy, :morale, :session_id])
    |> foreign_key_constraint(:session_id)
  end
end
