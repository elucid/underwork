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
      on :next, :cycling
      on :abort, :abandoned
    end

    # still belongs in session
    state :cycling do
      on :quit_session, :reviewing

      on_entry :next_cycle

      on :cycle_complete, :cycling # guard that maybe goes to review

      # inside the cycle workflow
      initial_state :planning

      on :finish_early, :reviewing
      on :abort, :abandoned

      state :planning do
        on :enter_work_mode, :working
      end

      # state :pre do
      #   on :work, :working
      #   on :done, :reviewing
      # end

      state :working do
        on :done, :reviewing # ie. done via timer
        on :return_to_plan, :planning
        # on :start_review, :reviewing  # TODO: end cycle and review early
      end

      state :reviewing do
        on_exit :update_current_cycle

        on :complete, :completed
      end

      state :completed do
        final
      end

    end

    state :reviewing do
      on :complete, :completed
    end

    state :abandoned

    state :completed
  end

  def next_cycle(%{session: session}) do
    # guard
    # * if cycle in progress, go to it
    # * else if cycles remaining, create new cycle, go to it
    # * else go to review
  end

  def update_current_cycle(%{session: session}) do
    # TODO
  end
end
