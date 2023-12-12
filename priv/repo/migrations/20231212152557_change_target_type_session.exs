defmodule Underwork.Repo.Migrations.ChangeTargetTypeSession do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      remove :target
    end

    alter table(:sessions) do
      add :target, :integer
    end
  end
end
