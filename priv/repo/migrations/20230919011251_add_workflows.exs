defmodule Underwork.Repo.Migrations.AddWorkflows do
  use Ecto.Migration

  def up do
    execute("create extension if not exists pgcrypto")

    ExState.Ecto.Migration.up()
  end

  def down do
  end
end
