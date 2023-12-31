defmodule Underwork.Cycles.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @min_cycles 2
  @max_cycles 18

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sessions" do
    field :state, :string, default: "new"
    field :target_cycles, :integer, default: @min_cycles
    field :start_at, :utc_datetime

    field :accomplish, :string
    field :complete, :string
    field :distractions, :string
    field :important, :string
    field :measurable, :string
    field :noteworthy, :string

    field :target, :integer
    field :done, :string
    field :compare, :string
    field :bogged, :string
    field :replicate, :string
    field :takeaways, :string

    has_many :cycles, Underwork.Cycles.Cycle

    timestamps(inserted_at: :created_at)
  end

  def min_cycles, do: @min_cycles
  def max_cycles, do: @max_cycles

  @doc false
  def cycles_changeset(session, attrs) do
    session
    |> cast(attrs, [:state, :target_cycles, :start_at])
    |> advance_state("new", "planning")
    |> validate_required([:target_cycles, :start_at])
    |> validate_number(:target_cycles, greater_than: 1, less_than: 19)
  end

  def planning_changeset(session, attrs) do
    session
    |> cast(attrs, [:accomplish, :important, :complete, :distractions, :measurable, :noteworthy])
    |> advance_state("planning", "working")
    |> validate_required([:accomplish])
  end

  def target_changeset(data, attrs) do
    data
    |> cast(attrs, [:target])
    |> validate_number(:target, greater_than_or_equal_to: 1, less_than_or_equal_to: 3)
  end

  def review_changeset(session, attrs) do
    session
    |> cast(attrs, [:target, :done, :compare, :bogged, :replicate, :takeaways])
    |> advance_state("reviewing", "complete")
    |> validate_required([:target, :done])
  end

  def work_changeset(session) do
    attrs = %{}

    session
    |> cast(attrs, [:state])
    |> advance_state("working", "reviewing")
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
