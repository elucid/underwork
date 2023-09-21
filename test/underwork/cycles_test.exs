defmodule Underwork.CyclesTest do
  use Underwork.DataCase

  alias Underwork.Cycles
  alias Underwork.Cycles.Sale
  alias Underwork.Cycles.User

  def create_sale do
    seller = User.new(%{name: "seller"}) |> Repo.insert!()
    buyer = User.new(%{name: "seller"}) |> Repo.insert!()

    Sale.new(%{
      product_id: "abc123",
      seller_id: seller.id,
      buyer_id: buyer.id
    })
    |> Repo.insert!()
  end

  def order_steps(steps) do
    Enum.sort_by(steps, &"#{&1.state}.#{&1.order}")
  end

  describe "create/1" do
    test "creates a workflow for a workflowable subject" do
      sale = create_sale()

      refute sale.workflow_id

      {:ok, %{context: %{sale: sale}}} = ExState.create(sale)

      assert sale.workflow.id

      refute sale.workflow.complete?
      assert sale.workflow.state == "pending"
      {:ok, sale} = ExState.complete(sale, :attach_document)
      assert sale.workflow.state == "pending"
      {:ok, sale} = ExState.complete(sale, :send)
      assert sale.workflow.state == "sent"

      sale2 = Repo.get!(Sale, sale.id) |> Repo.preload(workflow: :steps)
      dbg sale2
      assert sale2.workflow.state == "sent"
      {:ok, sale2} = ExState.complete(sale2, :close)
      assert sale2.workflow.state == "closed"
      assert sale2.workflow.complete?

      # dbg sale2.workflow.steps
      # assert [
      #          %{state: "pending", name: "attach_document", complete?: false},
      #          %{state: "pending", name: "send", complete?: false},
      #          %{state: "receipt_acknowledged", name: "close", complete?: false},
      #          %{state: "sent", name: "close", complete?: false},
      #          %{state: "sent", name: "acknowledge_receipt", complete?: false}
      #        ] = order_steps(sale.workflow.steps)
    end
  end

  describe "sessions" do
    alias Underwork.Cycles.Session

    import Underwork.CyclesFixtures

    @invalid_attrs %{accomplish: nil, complete: nil, distractions: nil, important: nil, measurable: nil, noteworthy: nil}

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert Cycles.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Cycles.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      valid_attrs = %{accomplish: "some accomplish", complete: "some complete", distractions: "some distractions", important: "some important", measurable: "some measurable", noteworthy: "some noteworthy"}

      assert {:ok, %Session{} = session} = Cycles.create_session(valid_attrs)
      assert session.accomplish == "some accomplish"
      assert session.complete == "some complete"
      assert session.distractions == "some distractions"
      assert session.important == "some important"
      assert session.measurable == "some measurable"
      assert session.noteworthy == "some noteworthy"
    end

    test "creating workflow for session" do
      valid_attrs = %{accomplish: "some accomplish", complete: "some complete", distractions: "some distractions", important: "some important", measurable: "some measurable", noteworthy: "some noteworthy"}
      assert {:ok, %Session{} = session} = Cycles.create_session(valid_attrs)

      assert {:ok, %{context: %{session: session}}} = ExState.create(session)
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cycles.create_session(@invalid_attrs)
    end

    test "update_session/2 with valid data updates the session" do
      session = session_fixture()
      update_attrs = %{accomplish: "some updated accomplish", complete: "some updated complete", distractions: "some updated distractions", important: "some updated important", measurable: "some updated measurable", noteworthy: "some updated noteworthy"}

      assert {:ok, %Session{} = session} = Cycles.update_session(session, update_attrs)
      assert session.accomplish == "some updated accomplish"
      assert session.complete == "some updated complete"
      assert session.distractions == "some updated distractions"
      assert session.important == "some updated important"
      assert session.measurable == "some updated measurable"
      assert session.noteworthy == "some updated noteworthy"
    end

    test "update_session/2 with invalid data returns error changeset" do
      session = session_fixture()
      assert {:error, %Ecto.Changeset{}} = Cycles.update_session(session, @invalid_attrs)
      assert session == Cycles.get_session!(session.id)
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = Cycles.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> Cycles.get_session!(session.id) end
    end

    test "change_session/1 returns a session changeset" do
      session = session_fixture()
      assert %Ecto.Changeset{} = Cycles.change_session(session)
    end
  end
end
