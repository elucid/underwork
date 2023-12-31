defmodule UnderworkWeb.WorkComponent do
  use UnderworkWeb, :live_component

  alias Underwork.Cycles

  def update(%{cycle: cycle, return: return}, socket) do
    send(self(), {__MODULE__, :start_timer})

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
      |> assign(:gong, nil)
      |> assign(:chime, nil)

    {:ok, socket}
  end

  def update(%{tick: :tick}, socket) do
    current_time = DateTime.utc_now()

    socket =
      socket
      |> assign(:current_time, current_time)

    socket =
      case DateTime.diff(socket.assigns.end_at, current_time, :second) do
        120 ->
          assign(socket, :gong, true)
        0 ->
          assign(socket, :chime, true)
        _ ->
          socket
        end

    {:ok, socket}
  end

  def handle_event("review", _, %{assigns: %{cycle: cycle}} = socket) do
    case Cycles.finish_work(cycle) do
      {:ok, cycle} ->
        socket =
          socket
          |> push_patch(to: ~p"/cycles")
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
        n = DateTime.diff(start_at, current_time, :second)
        n = div(n, 60) + if rem(n, 60) > 0, do: 1, else: 0
        "Prepare for your next cycle. Starting in #{n} minutes."
      DateTime.compare(current_time, end_at) == :gt ->
        "Done! Go ahead and review your cycle."
      DateTime.compare(current_time, DateTime.add(end_at, -60, :second)) == :gt ->
        n = DateTime.diff(end_at, current_time, :second)
        "#{n} seconds remaining"
      true ->
        diff_in_seconds = DateTime.diff(end_at, current_time, :second)
        n = div(diff_in_seconds, 60) + if rem(diff_in_seconds, 60) > 0, do: 1, else: 0
        "#{n} minutes remaining"
    end
  end
end
