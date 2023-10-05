defmodule Underwork.Repo.Migrations.AddWorkflowToCycles do
  use Ecto.Migration

  def change do
    alter table(:cycles) do
      add :workflow_id, references(:workflows, type: :uuid)
    end
  end
end
