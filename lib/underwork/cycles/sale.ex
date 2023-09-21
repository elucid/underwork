defmodule Underwork.Cycles.Sale do
  use Ecto.Schema
  use ExState.Ecto.Subject

  import Ecto.Changeset

  alias Underwork.Cycles.SaleWorkflow
  alias Underwork.Cycles.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sales" do
    has_workflow SaleWorkflow
    field :product_id, :string
    field :cancelled_at, :utc_datetime
    belongs_to :seller, User
    belongs_to :buyer, User
  end

  def new(params) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(sale, params) do
    sale
    |> cast(params, [
      :product_id,
      :cancelled_at,
      :seller_id,
      :buyer_id,
      :workflow_id
    ])
    |> validate_required([:product_id])
  end
end
