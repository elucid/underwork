defmodule UnderworkWeb.SessionLive.Work do
  use UnderworkWeb, :live_view

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

  def handle_event("review", _, socket) do
    cycle = socket.assigns.cycle

    case Cycles.finish_work(cycle) do
      {:ok, cycle} ->
        socket =
          socket
          |> put_flash(:info, "YAY")
          |> push_navigate(to: ~p"/sessions/#{cycle.session_id}/cycle/#{cycle.id}/review")

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end

  # def handle_event("plan", _, socket) do
  #   cycle = socket.assigns.cycle

  #   socket = socket |> push_redirect(to: ~p"/sessions/#{cycle.session_id}/cycle/#{cycle.id}/plan")

  #   {:noreply, socket}
  # end
end
