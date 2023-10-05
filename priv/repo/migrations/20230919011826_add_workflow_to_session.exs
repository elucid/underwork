defmodule Underwork.Repo.Migrations.AddWorkflowToSession do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      add :workflow_id, references(:workflows, type: :uuid)
    end
  end
end
