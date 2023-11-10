defmodule UnderworkWeb.CyclesLive do
  use UnderworkWeb, :live_view

  alias Underwork.Cycles

  @impl true
  def mount(_params, _session, socket) do
    session = Cycles.current_session_for_user()

    socket =
    socket
    |> assign(:session, session)
    |> stream(:cycles, session.cycles)

    {:ok, socket}
  end

  def handle_info({component = UnderworkWeb.WorkComponent, :tick}, socket) do
    send_update(component, id: "working-cycle", tick: :tick)

    {:noreply, socket}
  end

  def handle_info({_module, :next_cycle}, socket) do
    next_cycle = Cycles.next_cycle(socket.assigns.session)

    socket =
      if next_cycle do
        stream_insert(socket, :cycles, next_cycle)
      else
        session = Cycles.current_session_for_user()
        assign(socket, :session, session)
      end

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_info({_module, {:cycle_changed, cycle}}, socket) do
    {:noreply, stream_insert(socket, :cycles, cycle)}
  end
end
