defmodule Underwork.Repo.Migrations.AddTargetCyclesToSessions do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      add :target_cycles, :integer
    end
  end
end
