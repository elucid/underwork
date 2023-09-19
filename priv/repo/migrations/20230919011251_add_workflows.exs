defmodule Underwork.Repo.Migrations.AddWorkflows do
  use Ecto.Migration

  def up do
    ExState.Ecto.Migration.up(install_pgcrypto: true)
  end

  def down do
  end
end
