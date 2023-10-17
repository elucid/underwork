defmodule UnderworkWeb.SessionLive.Plan do
  use UnderworkWeb, :live_view

  alias Underwork.Cycles

  def mount(%{"id" => session_id}, _session, socket) do
    session = Cycles.get_session!(session_id)
    changeset = Cycles.change_session_plan(session)
    form = to_form(changeset)

    socket =
      socket
      |> assign(:session, session)
      |> assign(:form, form)

    {:ok, socket}
  end

  def handle_event("validate", %{"session" => params}, socket) do
    changeset =
      socket.assigns.session
      |> Cycles.change_session_plan(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"session" => params}, socket) do
    session = socket.assigns.session

    case Cycles.plan_session(session, params) do
      {:ok, _session} ->
        socket =
          socket
          |> put_flash(:info, "YAY")
          |> push_navigate(to: next_cycle_path(session))

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end

  # TODO: stick this some place where multiple LiveViews and components can see
  defp next_cycle_path(session) do
    last_cycle = List.last(session.cycles)

    cond do
      session.cycles == [] ->
        ~p"/sessions/#{session.id}/cycle/new"
      last_cycle.state != "reviewed" ->
        ~p"/sessions/#{session.id}/cycle/#{last_cycle}"
      length(session.cycles) < session.target_cycles ->
        ~p"/sessions/#{session.id}/cycle/new"
      true ->
        ~p"/sessions/#{session.id}/review"
    end
  end
end
