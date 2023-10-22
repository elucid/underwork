defmodule Underwork.Repo.Migrations.AddCycleReviewFields do
  use Ecto.Migration

  def change do
    alter table(:cycles) do
      add :target, :string
      add :noteworthy, :text
      add :distractions, :text
      add :improve, :text
    end
  end
end
