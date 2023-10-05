defmodule Underwork.CyclesTest do
  use Underwork.DataCase

  alias Underwork.Cycles

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

  describe "cycles" do
    alias Underwork.Cycles.Cycle

    import Underwork.CyclesFixtures

    @invalid_attrs %{accomplish: nil, energy: nil, hazards: nil, morale: nil, started: nil}

    test "list_cycles/0 returns all cycles" do
      cycle = cycle_fixture(session_id: session_fixture().id)
      assert Cycles.list_cycles() == [cycle]
    end

    test "get_cycle!/1 returns the cycle with given id" do
      cycle = cycle_fixture(session_id: session_fixture().id)
      assert Cycles.get_cycle!(cycle.id) == cycle
    end

    test "create_cycle/1 with valid data creates a cycle" do
      valid_attrs = %{accomplish: "some accomplish", energy: 42, hazards: "some hazards", morale: 42, started: "some started", session_id: session_fixture().id}

      assert {:ok, %Cycle{} = cycle} = Cycles.create_cycle(valid_attrs)
      assert cycle.accomplish == "some accomplish"
      assert cycle.energy == 42
      assert cycle.hazards == "some hazards"
      assert cycle.morale == 42
      assert cycle.started == "some started"
    end

    test "create_cycle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cycles.create_cycle(@invalid_attrs)
    end

    test "update_cycle/2 with valid data updates the cycle" do
      cycle = cycle_fixture(session_id: session_fixture().id)
      update_attrs = %{accomplish: "some updated accomplish", energy: 43, hazards: "some updated hazards", morale: 43, started: "some updated started"}

      assert {:ok, %Cycle{} = cycle} = Cycles.update_cycle(cycle, update_attrs)
      assert cycle.accomplish == "some updated accomplish"
      assert cycle.energy == 43
      assert cycle.hazards == "some updated hazards"
      assert cycle.morale == 43
      assert cycle.started == "some updated started"
    end

    test "update_cycle/2 with invalid data returns error changeset" do
      cycle = cycle_fixture(session_id: session_fixture().id)
      assert {:error, %Ecto.Changeset{}} = Cycles.update_cycle(cycle, @invalid_attrs)
      assert cycle == Cycles.get_cycle!(cycle.id)
    end

    test "delete_cycle/1 deletes the cycle" do
      cycle = cycle_fixture(session_id: session_fixture().id)
      assert {:ok, %Cycle{}} = Cycles.delete_cycle(cycle)
      assert_raise Ecto.NoResultsError, fn -> Cycles.get_cycle!(cycle.id) end
    end

    test "change_cycle/1 returns a cycle changeset" do
      cycle = cycle_fixture(session_id: session_fixture().id)
      assert %Ecto.Changeset{} = Cycles.change_cycle(cycle)
    end
  end
end
