defmodule Underwork.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :state, :string, null: false, default: "new"
      add :accomplish, :text
      add :important, :text
      add :complete, :text
      add :distractions, :text
      add :measurable, :text
      add :noteworthy, :text

      timestamps(inserted_at: :created_at)
    end
  end
end
