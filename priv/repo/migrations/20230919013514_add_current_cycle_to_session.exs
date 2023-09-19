defmodule Underwork.Repo.Migrations.AddCurrentCycleToSession do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      add :current_cycle, :integer, default: 0, null: false
    end
  end
end
