defmodule Underwork.Cycles.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sessions" do
    field :accomplish, :string
    field :complete, :string
    field :distractions, :string
    field :important, :string
    field :measurable, :string
    field :noteworthy, :string
    field :target_cycles, :integer, default: 2
    field :start_at, :utc_datetime

    has_many :cycles, Underwork.Cycles.Cycle

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def cycles_changeset(session, attrs) do
    session
    |> cast(attrs, [:target_cycles, :start_at])
    |> validate_required([:target_cycles, :start_at])
    |> validate_number(:target_cycles, greater_than: 1, less_than: 19)
  end

  def planning_changeset(session, attrs) do
    session
    |> cast(attrs, [:accomplish, :important, :complete, :distractions, :measurable, :noteworthy])
    |> validate_required([:accomplish, :important, :complete, :distractions, :measurable, :noteworthy])
  end
end
