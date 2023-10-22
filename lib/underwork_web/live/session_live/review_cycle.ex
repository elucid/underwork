defmodule UnderworkWeb.SessionLive.ReviewCycle do
  use UnderworkWeb, :live_view
  import UnderworkWeb.Helpers

  alias Underwork.Cycles

  def mount(%{"id" => cycle_id}, _session, socket) do
    cycle = Cycles.get_cycle!(cycle_id)
    changeset = Cycles.change_cycle_plan(cycle)
    form = to_form(changeset)

    socket =
      socket
      |> assign(:cycle, cycle)
      |> assign(:form, form)

    {:ok, socket}
  end

  def handle_event("validate", %{"cycle" => params}, socket) do
    changeset =
      socket.assigns.cycle
      |> Cycles.change_cycle_plan(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"cycle" => params}, socket) do
    cycle = socket.assigns.cycle

    case Cycles.review_cycle(cycle, params) do
      {:ok, cycle} ->
        session = Cycles.get_session!(cycle.session_id)

        socket =
          socket
          |> put_flash(:info, "YAY")
          |> push_navigate(to: next_cycle_path(session, Cycles.next_cycle(session)))

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end
end
