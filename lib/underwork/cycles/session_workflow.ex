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
      on :start, :pre
      on :abort, :abandoned
    end

    state :pre do
      on :cycle, :cycling
      on :finish, :reviewing
    end

    state :cycling do
      initial_state :planning

      on :finish_early, :reviewing
      on :abort, :abandoned

      state :planning do
        on :start_cycle, :pre
      end

      state :pre do
        on :work, :working
        on :done, :reviewing
      end

      state :working do
        on :done, :reviewing
        on :plan, :planning
      end

      state :reviewing do
        on_exit :update_current_cycle

        on :complete, :pre
      end
    end

    state :reviewing do
      on :complete, :completed
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
