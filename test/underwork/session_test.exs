defmodule Underwork.SessionTest do
  use Underwork.DataCase, async: true

  alias Underwork.Session

  test "can move through a session with 2 work cycles" do
    Session.create(cycles: 2)
    |> Session.plan()
    |> Session.start()
    |> Session.next_cycle_or_finish()
    |> Session.start_cycle()
    |> Session.work()
    |> Session.done()
    |> Session.complete()
    |> Session.next_cycle_or_finish()
    |> assert_in_states([:cycling, :cycling_planning])
    |> Session.start_cycle()
    |> Session.work()
    |> Session.done()
    |> Session.complete()
    |> Session.next_cycle_or_finish()
    |> assert_in_states([:reviewing])
    |> Session.start_cycle()
    |> assert_error()
  end

  defp assert_in_states(session, states) do
    assert Statechart.states(session) == states
    session
  end

  defp assert_error(session) do
    assert Statechart.last_event_status(session) == :error
    session
  end
end
