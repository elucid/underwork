defmodule UnderworkWeb.WorkComponent do
  use UnderworkWeb, :live_component

  alias Underwork.Cycles

  def update(%{cycle: cycle, return: return}, socket) do
    changeset = Cycles.change_cycle_plan(cycle)
    form = to_form(changeset)

    socket =
      socket
      |> assign(:cycle, cycle)
      |> assign(:form, form)
      |> assign(:return, return)

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
end
