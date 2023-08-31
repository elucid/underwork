defmodule Underwork.Session do
  use Statechart

  statechart default: :created, context: {map, %{total_cycles: 9, current_cycle: 0}} do
    state :created do
      :PLAN >>> :planning
    end

    state :planning do
      :START >>> :pre
      :ABORT >>> :abandoned
    end

    state :pre do
      :CYCLE >>> :cycling
      :FINISH >>> :reviewing
    end

    state :cycling, default: :cycling_planning do
      :FINISH_EARLY >>> :reviewing
      :ABORT >>> :abandoned

      state :cycling_planning do
        :START_CYCLE >>> :cycling_pre
      end

      state :cycling_pre do
        :WORK >>> :cycling_working
        :DONE >>> :cycling_reviewing
      end

      state :cycling_working do
        :DONE >>> :cycling_reviewing
        :PLAN >>> :cycling_planning
      end

      state :cycling_reviewing,
        exit: fn context ->
          Map.update!(context, :current_cycle, &(&1 + 1))
        end do
        :COMPLETE >>> :pre
      end
    end

    state :reviewing do
      :COMPLETE >>> :completed
    end

    state(:abandoned)
    state(:completed)
  end

  def create(cycle_count) do
    new()
    |> set_total_cycles(cycle_count)
  end

  def set_total_cycles(session, count) do
    put_in(session.context.total_cycles, count)
  end

  def plan(session) do
    Statechart.trigger(session, :PLAN)
  end

  def start(session) do
    Statechart.trigger(session, :START)
  end

  def next_cycle_or_finish(session) do
    if session.context.current_cycle == session.context.total_cycles do
      Statechart.trigger(session, :FINISH)
    else
      Statechart.trigger(session, :CYCLE)
    end
  end

  def finish_early(session) do
    Statechart.trigger(session, :FINISH_EARLY)
  end

  def abort(session) do
    Statechart.trigger(session, :ABORT)
  end

  def start_cycle(session) do
    Statechart.trigger(session, :START_CYCLE)
  end

  def work(session) do
    Statechart.trigger(session, :WORK)
  end

  def done(session) do
    Statechart.trigger(session, :DONE)
  end

  def complete(session) do
    Statechart.trigger(session, :COMPLETE)
  end

  def next(session) do
    Statechart.trigger(session, :NEXT)
  end
end
