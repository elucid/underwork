defmodule Underwork.Repo.Migrations.AddSessionReviewTarget do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      add :target, :string
    end
  end
end
