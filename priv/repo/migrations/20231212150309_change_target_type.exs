defmodule Underwork.Repo.Migrations.ChangeTargetType do
  use Ecto.Migration

  def change do
    alter table(:cycles) do
      remove :target
    end

    alter table(:cycles) do
      add :target, :integer
    end
  end
end
