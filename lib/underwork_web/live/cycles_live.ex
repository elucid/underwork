defmodule UnderworkWeb.CyclesLive do
  use UnderworkWeb, :live_view

  alias Underwork.Cycles

  @impl true
  def mount(_params, _session, socket) do
    session = Cycles.current_session_for_user()

    socket =
    socket
    |> assign(:session, session)
    |> assign(:cycles, session.cycles)

    {:ok, socket}
  end

  def handle_info({_module, :next_cycle}, socket) do
    next_cycle = Cycles.next_cycle(socket.assigns.session)

    {:noreply, stream_insert(socket, :cycles, next_cycle)}
  end
end
