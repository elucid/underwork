defmodule Underwork.Cycles.Cycle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cycles" do
    field :state, :string, default: "planning"
    field :number, :integer

    field :accomplish, :string
    field :energy, :integer
    field :hazards, :string
    field :morale, :integer
    field :started, :string

    field :target, :integer
    field :noteworthy, :string
    field :distractions, :string
    field :improve, :string

    belongs_to :session, Underwork.Cycles.Session

    timestamps(inserted_at: :created_at)
  end

  # TODO: get rid of this once we've built out more of the other changesets
  def changeset(cycle, attrs) do
    cycle
    |> cast(attrs, [:state, :accomplish, :started, :hazards, :energy, :morale, :session_id, :number])
    |> validate_required([:session_id, :number])
    |> foreign_key_constraint(:session_id)
  end

  def create_changeset(cycle, attrs) do
    cycle
    |> cast(attrs, [:state, :session_id, :number])
    |> validate_required([:state, :session_id, :number])
    |> foreign_key_constraint(:session_id)
  end

  def assessment_changeset(cycle_or_changeset, attrs) do
    cycle_or_changeset
    |> cast(attrs, [:energy, :morale])
    |> validate_number(:energy, greater_than_or_equal_to: 1, less_than_or_equal_to: 3)
    |> validate_number(:morale, greater_than_or_equal_to: 1, less_than_or_equal_to: 3)
  end

  def target_changeset(cycle_or_changeset, attrs) do
    cycle_or_changeset
    |> cast(attrs, [:target])
    |> validate_number(:target, greater_than_or_equal_to: 1, less_than_or_equal_to: 3)
  end

  def planning_changeset(cycle, attrs) do
    cycle
    |> cast(attrs, [:state, :accomplish, :started, :hazards, :energy, :morale, :session_id])
    |> advance_state("planning", "working")
    |> validate_required([:accomplish, :session_id])
    |> foreign_key_constraint(:session_id)
  end

  def work_changeset(cycle) do
    attrs = %{}

    cycle
    |> cast(attrs, [:state])
    |> advance_state("working", "reviewing")
  end

  def review_changeset(cycle, attrs) do
    cycle
    |> cast(attrs, [:state, :target, :noteworthy, :distractions, :improve])
    |> advance_state("reviewing", "complete")
    |> validate_required([:target])
  end

  def advance_state(%Ecto.Changeset{data: %{state: state}} = changeset, from_state, to_state) do
    changeset = delete_change(changeset, :state)

    case state do
      ^from_state ->
         changeset |> put_change(:state, to_state)
      _ -> changeset
    end
  end
end
