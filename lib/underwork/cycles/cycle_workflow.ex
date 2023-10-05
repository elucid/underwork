defmodule Underwork.Cycles.CycleWorkflow do
  use ExState.Definition

  alias Underwork.Repo
  alias Underwork.Cycles.Cycle

  workflow "cycle" do
    subject :cycle, Cycle

    initial_state :planning

    state :planning do
      step :start
      on_completed :start, :working
    end

    state :working do
      step :timeout
      on_completed :timeout, :done # TODO: write test that skips this step. failz?

      step :start_review
      on_completed :start_review, :reviewing
    end

    state :done do
      step :start_review
      on_completed :start_review, :reviewing
    end

    state :reviewing do
      step :complete
      on_completed :complete, :completed
    end

    state :completed do
      final
    end
  end
end
