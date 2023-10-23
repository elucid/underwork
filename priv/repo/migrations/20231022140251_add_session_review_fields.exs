defmodule Underwork.Repo.Migrations.AddSessionReviewFields do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      add :done, :text
      add :compare, :text
      add :bogged, :text
      add :replicate, :text
      add :takeaways, :text
    end
  end
end
