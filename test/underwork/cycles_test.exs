defmodule Underwork.CyclesTest do
  use Underwork.DataCase, async: true

  import Underwork.CyclesFixtures

  alias Underwork.Cycles
  alias Underwork.Cycles.Session
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
        number: 1,
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

  describe "configure_session" do
    test "ignores passed in state" do
      session = %Session{}
      attrs = %{target_cycles: 3, state: "working", start_at: DateTime.from_naive!(~N[2023-10-20 06:10:00], "Etc/UTC")}

      {:ok, session} = Cycles.configure_session(session, attrs)

      assert session.state == "planning"
      assert session.target_cycles == 3
    end

    test "sets state to \"planning\" with a new session" do
      session = %Session{}
      attrs = %{target_cycles: 3, start_at: DateTime.from_naive!(~N[2023-10-20 06:10:00], "Etc/UTC")}

      {:ok, session} = Cycles.configure_session(session, attrs)

      assert session.state == "planning"
      assert session.target_cycles == 3
    end

    test "updates target_cycles but not state for an existing session" do
      session = %Session{}
      attrs = %{target_cycles: 3, start_at: DateTime.from_naive!(~N[2023-10-20 06:10:00], "Etc/UTC")}

      {:ok, session} = Cycles.configure_session(session, attrs)

      {:ok, session} =
        session
        |> Ecto.Changeset.change(%{state: "working"})
        |> Repo.update()

      assert session.state == "working"

      attrs = %{target_cycles: 4}
      {:ok, session} = Cycles.configure_session(session, attrs)

      assert session.target_cycles == 4
      assert session.state == "working"
    end
  end

  describe "#plan_session" do
    test "transitions to working" do
      session = %Session{}
      attrs = %{target_cycles: 3, start_at: DateTime.from_naive!(~N[2023-10-20 06:10:00], "Etc/UTC")}

      {:ok, session} = Cycles.configure_session(session, attrs)
      assert session.state == "planning"

      {:ok, session} = Cycles.plan_session(session, %{accomplish: "some accomplish"})
      assert session.state == "working"
    end
  end

  describe "#next_cycle" do
    test "when there are fewer cycles than target cycles" do
      session = session_fixture(target_cycles: 2)

      cycle = Cycles.next_cycle(session)
      assert match?(%Cycle{}, cycle)
      assert cycle.state == "planning"
    end

    test "when there are cycles, but not enough of them" do
      session = session_fixture(target_cycles: 2)
      existing_cycle = cycle_fixture(session_id: session.id, state: "complete", number: 1)

      cycle = Cycles.next_cycle(session)

      assert match?(%Cycle{}, cycle)
      assert cycle.id != existing_cycle
      assert cycle.state == "planning"
      assert cycle.number == 2
    end

    test "When the current cycle is underway, return the current cycle" do
      session = session_fixture(target_cycles: 2)
      existing_cycle = cycle_fixture(session_id: session.id, state: "planned", number: 1)

      cycle = Cycles.next_cycle(session)

      assert cycle == existing_cycle
    end

    test "2 cycles, both reviewed" do
      session = session_fixture(target_cycles: 2)
      cycle_fixture(session_id: session.id, state: "complete", number: 1)
      cycle_fixture(session_id: session.id, state: "complete", number: 2)

      cycle = Cycles.next_cycle(session)

      assert cycle == nil
    end

    test "2 cycles, last one is not reviewed" do
      session = session_fixture(target_cycles: 2)
      _cycle1 = cycle_fixture(session_id: session.id, state: "reviewed", number: 1)
      cycle2 = cycle_fixture(session_id: session.id, state: "planning", number: 2)

      cycle = Cycles.next_cycle(session)

      assert cycle == cycle2
    end
  end

  describe "#plan_cycle" do
    test "transitions to working" do
      session = session_fixture(target_cycles: 2)

      cycle = Cycles.next_cycle(session)
      assert match?(%Cycle{}, cycle)
      assert cycle.state == "planning"

      {:ok, cycle} = Cycles.plan_cycle(cycle, %{accomplish: "some accomplish"})
      assert cycle.state == "working"
    end
  end

  describe "#finish_work" do
    test "transitions to reviewing" do
      session = session_fixture(target_cycles: 2)

      cycle = cycle_fixture(session_id: session.id, state: "working")
      {:ok, cycle} = Cycles.finish_work(cycle)
      assert cycle.state == "reviewing"
    end
  end

  describe "#review_cycle" do
    test "transitions to complete" do
      session = session_fixture(target_cycles: 2)

      cycle = cycle_fixture(session_id: session.id, state: "reviewing")

      {:ok, cycle} = Cycles.review_cycle(cycle, %{target: "Yes"})
      assert cycle.state == "complete"
    end
  end

  describe "#review_session" do
    test "transitions to complete" do
      session = session_fixture(target_cycles: 2, state: "reviewing")

      cycle_fixture(session_id: session.id, state: "complete", number: 1)
      cycle_fixture(session_id: session.id, state: "complete", number: 2)

      {:ok, session} = Cycles.finish_work(session)
      assert session.state == "reviewing"
      {:ok, session} = Cycles.review_session(session, %{done: "some done"})
      assert session.state == "complete"
    end
  end

  describe "cycle time math" do
    test "cycle start relative to session start" do
      start_at = ~U[2023-10-10 10:10:00Z]
      session = session_fixture(target_cycles: 3, state: "working", start_at: start_at)

      cycle_fixture(session_id: session.id, state: "complete", number: 1)
      cycle_fixture(session_id: session.id, state: "complete", number: 2)
      cycle_3 = cycle_fixture(session_id: session.id, state: "complete", number: 3)

      assert Cycles.start_at(cycle_3) == ~U[2023-10-10 11:30:00Z]
    end
  end
end
