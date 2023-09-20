defmodule Underwork.SessionWorkflowTest do
  use Underwork.DataCase, async: false

  alias Underwork.Cycles.SessionWorkflow

  test "can move through a session with 2 work cycles" do
    SessionWorkflow.new(%{cycles: 2})
    # |> IO.inspect()
    |> SessionWorkflow.transition_maybe(:plan)
    |> assert_in_states("planning")
    |> SessionWorkflow.transition_maybe(:start)
    # |> SessionWorkflow.next_cycle_or_finish()
    |> SessionWorkflow.transition_maybe(:cycle)
    |> SessionWorkflow.transition_maybe(:start_cycle)
    |> assert_in_states("cycling.pre")
    |> SessionWorkflow.transition_maybe(:work)
    |> assert_in_states("cycling.working")
    |> SessionWorkflow.transition_maybe(:done)
    |> SessionWorkflow.transition_maybe(:work)
    |> SessionWorkflow.transition_maybe(:done)
    |> SessionWorkflow.transition_maybe(:complete)
    # |> SessionWorkflow.next_cycle_or_finish()
    |> SessionWorkflow.transition_maybe(:cycle)
    |> assert_in_states("cycling.planning")
    |> SessionWorkflow.transition_maybe(:start_cycle)
    |> SessionWorkflow.transition_maybe(:work)
    # |> assert_in_states([:cycling, :cycling_planning])
    |> assert_in_states("cycling.planning")
    # |> SessionWorkflow.start_cycle()
    # |> SessionWorkflow.work()
    # |> SessionWorkflow.done()
    # |> SessionWorkflow.complete()
    # |> SessionWorkflow.next_cycle_or_finish()
    # |> assert_in_states([:reviewing])
    # |> SessionWorkflow.start_cycle()
    # |> assert_error()
  end

  defp assert_in_states(session, states) do
    assert Map.get(Map.get(session, :state), :name) == states
    session
  end

  defp assert_error(session) do
    assert Statechart.last_event_status(session) == :error
    session
  end
end
