defmodule Underwork.Repo.Migrations.CreateCycles do
  use Ecto.Migration

  def change do
    create table(:cycles) do
      add :accomplish, :text
      add :started, :text
      add :hazards, :text
      add :energy, :integer
      add :morale, :integer
      add :session_id, references(:sessions, type: :binary_id, on_delete: :nothing)

      timestamps()
    end
  end
end
