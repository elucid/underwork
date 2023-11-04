defmodule Underwork.Repo.Migrations.AddCycleNumber do
  use Ecto.Migration

  def change do
    alter table(:cycles) do
      add :number, :integer, null: false
    end

    create unique_index(:cycles, [:session_id, :number])
  end
end
