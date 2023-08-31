defmodule Underwork.SessionTest do
  use Underwork.DataCase, async: true

  alias Underwork.Session

  test "creates a new statechart" do
    session = Session.create(2)
    |> Session.plan()
    |> Session.start()
    |> Session.next_cycle_or_finish()
    |> Session.start_cycle()
    |> Session.work()
    |> Session.done()
    |> Session.complete()
    |> Session.next_cycle_or_finish()
    |> Session.start_cycle()
    |> Session.work()
    |> Session.done()
    |> Session.complete()
    |> Session.next_cycle_or_finish()
    |> dbg
    assert Statechart.states(session) == [:cycling, :cycling_planning]
  end

end
