defmodule UnderworkWeb.PlanCycleComponent do
  use UnderworkWeb, :live_component

  alias Underwork.Cycles

  def update(%{cycle: cycle}, socket) do
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

    case Cycles.plan_cycle(cycle, params) do
      {:ok, cycle} ->
        socket =
          if cycle.state == "working" do
            socket
            |> push_patch(to: ~p"/cycles/work")
          else
            socket
          end

        send(self(), {__MODULE__, :next_cycle})

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end
end
