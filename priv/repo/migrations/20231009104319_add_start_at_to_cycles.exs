defmodule Underwork.Repo.Migrations.AddStartAtToCycles do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      add :start_at, :utc_datetime
    end
  end
end
