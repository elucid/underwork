defmodule Underwork.Cycles.Cycle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cycles" do
    field :state, :string, default: "new"
    field :accomplish, :string
    field :energy, :integer
    field :hazards, :string
    field :morale, :integer
    field :started, :string

    belongs_to :session, Underwork.Cycles.Session

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(cycle, attrs) do
    cycle
    |> cast(attrs, [:state, :accomplish, :started, :hazards, :energy, :morale, :session_id])
    |> validate_required([:session_id])
    |> foreign_key_constraint(:session_id)
  end

  @doc false
  def planning_changeset(cycle, attrs) do
    cycle
    |> cast(attrs, [:state, :accomplish, :started, :hazards, :energy, :morale, :session_id])
    |> validate_required([:accomplish])
    |> foreign_key_constraint(:session_id)
  end
end
