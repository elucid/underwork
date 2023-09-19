defmodule Underwork.Repo.Migrations.AddTestModelsFromLib do
  use Ecto.Migration

  def up do
    create table(:users) do
      add(:name, :string, null: false)
    end

    # ExState.Ecto.Migration.up(install_pgcrypto: true)

    create table(:sales) do
      add(:product_id, :string, null: false)
      add(:cancelled_at, :utc_datetime)
      add(:seller_id, references(:users, type: :uuid))
      add(:buyer_id, references(:users, type: :uuid))
      add(:workflow_id, references(:workflows, type: :uuid))
    end
  end
end
