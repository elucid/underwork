defmodule Underwork.Cycles.Session do
  use Ecto.Schema
  use ExState.Ecto.Subject

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

    has_workflow Underwork.Cycles.SessionWorkflow

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:accomplish, :important, :complete, :distractions, :measurable, :noteworthy])
    |> validate_required([:accomplish, :important, :complete, :distractions, :measurable, :noteworthy])
  end
end
