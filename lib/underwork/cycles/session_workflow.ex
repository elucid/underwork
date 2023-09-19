defmodule Underwork.Cycles.SessionWorkflow do
  use ExState.Definition

  alias Underwork.Repo
  alias Underwork.Cycles.Session

  workflow "session" do
    subject :session, Session

    initial_state :created

    state :created do
      on :plan, :planning
    end

    state :planning do
      on :cancel, :cancelled
    end

    state :planning do
      on :START, :pre
      on :ABORT, :abandoned
    end

    state :pre do
      on :CYCLE, :cycling
      on :FINISH, :reviewing
    end

    state :cycling do
      initial_state :cycling_planning

      on :FINISH_EARLY, :reviewing
      on :ABORT, :abandoned

      state :cycling_planning do
        on :START_CYCLE, :cycling_pre
      end

      state :cycling_pre do
        on :WORK, :cycling_working
        on :DONE, :cycling_reviewing
      end

      state :cycling_working do
        on :DONE, :cycling_reviewing
        on :PLAN, :cycling_planning
      end

      state :cycling_reviewing do
        on_exit :update_current_cycle

        on :COMPLETE, :pre
      end
    end

    state :reviewing do
      on :COMPLETE, :completed
    end

    state :abandoned

    state :completed
  end

  def update_current_cycle(%{session: session}) do
    session
    |> Session.changeset(%{current_cycle: session.current_cycle + 1})
    |> Repo.update()
  end
end
