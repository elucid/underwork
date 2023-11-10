defmodule UnderworkWeb.WorkComponent do
  use UnderworkWeb, :live_component

  alias Underwork.Cycles

  def update(%{cycle: cycle, return: return}, socket) do
    socket =
      if socket.assigns[:work_timer] do
        socket
      else
        work_timer = :timer.send_interval(1000, self(), {__MODULE__, :tick})
        assign(socket, :work_timer, work_timer)
      end

    changeset = Cycles.change_cycle_plan(cycle)
    form = to_form(changeset)

    socket =
      socket
      |> assign(:current_time, DateTime.utc_now())
      |> assign(:start_at, Cycles.start_at(cycle))
      |> assign(:end_at, Cycles.end_at(cycle))
      |> assign(:cycle, cycle)
      |> assign(:form, form)
      |> assign(:return, return)

    {:ok, socket}
  end

  def update(%{tick: :tick}, socket) do
    socket =
      socket
      |> assign(:current_time, DateTime.utc_now())

    {:ok, socket}
  end

  def handle_event("review", _, %{assigns: %{cycle: cycle}} = socket) do
    case Cycles.finish_work(cycle) do
      {:ok, cycle} ->
        socket =
          socket
          |> put_flash(:info, "YAY")

        send(self(), {__MODULE__, {:cycle_changed, cycle}})

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end

  def remaining_time_message(start_at, end_at, current_time) do
    cond do
      DateTime.compare(current_time, start_at) == :lt ->
        n = DateTime.diff(start_at, current_time, :minute)
        "Prepare for your next cycle. Starting in #{n} minutes"
      DateTime.compare(current_time, end_at) == :gt ->
        "Done"
      DateTime.compare(current_time, DateTime.add(end_at, -60, :second)) == :gt ->
        n = DateTime.diff(end_at, current_time, :second)
        "#{n} seconds remaining"
      true ->
        n = DateTime.diff(end_at, current_time, :minute)
        "#{n} minutes remaining"
    end
  end
end
