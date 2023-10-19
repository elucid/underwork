defmodule Underwork.CyclesTest do
  use Underwork.DataCase, async: true

  import Underwork.CyclesFixtures

  alias Underwork.Cycles
  alias Underwork.Cycles.Cycle

  describe "sessions" do
    @invalid_attrs %{
      accomplish: nil,
      complete: nil,
      distractions: nil,
      important: nil,
      measurable: nil,
      noteworthy: nil
    }

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert Cycles.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Cycles.get_session!(session.id) == session
    end
  end

  describe "cycles" do
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
      valid_attrs = %{
        accomplish: "some accomplish",
        energy: 42,
        hazards: "some hazards",
        morale: 42,
        started: "some started",
        session_id: session_fixture().id
      }

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

      update_attrs = %{
        accomplish: "some updated accomplish",
        energy: 43,
        hazards: "some updated hazards",
        morale: 43,
        started: "some updated started"
      }

      assert {:ok, %Cycle{} = cycle} = Cycles.update_cycle(cycle, update_attrs)
      assert cycle.accomplish == "some updated accomplish"
      assert cycle.energy == 43
      assert cycle.hazards == "some updated hazards"
      assert cycle.morale == 43
      assert cycle.started == "some updated started"
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

  describe "#next_cycle" do
    test "when there are fewer cycles than target cycles" do
      session = session_fixture(target_cycles: 2)

      cycle = Cycles.next_cycle(session)
      assert match?(%Cycle{}, cycle)
      assert cycle.state == "new"
    end

    test "when there are cycles, but not enough of them" do
      session = session_fixture(target_cycles: 2)
      existing_cycle = cycle_fixture(session_id: session.id, state: "reviewed")

      cycle = Cycles.next_cycle(session)

      assert match?(%Cycle{}, cycle)
      assert cycle.id != existing_cycle
    end

    test "When the current cycle is underway, return the current cycle" do
      session = session_fixture(target_cycles: 2)
      existing_cycle = cycle_fixture(session_id: session.id, state: "planned")

      cycle = Cycles.next_cycle(session)

      assert cycle == existing_cycle
    end

    test "2 cycles, both reviewed" do
      session = session_fixture(target_cycles: 2)
      cycle_fixture(session_id: session.id, state: "reviewed")
      cycle_fixture(session_id: session.id, state: "reviewed")

      cycle = Cycles.next_cycle(session)

      assert cycle == nil
    end

    test "2 cycles, last one is not reviewed" do
      session = session_fixture(target_cycles: 2)
      _cycle1 = cycle_fixture(session_id: session.id, state: "reviewed")
      cycle2 = cycle_fixture(session_id: session.id, state: "planning")

      cycle = Cycles.next_cycle(session)

      assert cycle == cycle2
    end
  end
end
