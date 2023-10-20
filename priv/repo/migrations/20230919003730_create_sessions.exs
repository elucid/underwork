defmodule Underwork.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :state, :string, null: false, default: "new"
      add :accomplish, :string
      add :important, :string
      add :complete, :string
      add :distractions, :string
      add :measurable, :string
      add :noteworthy, :string

      timestamps(inserted_at: :created_at)
    end
  end
end
