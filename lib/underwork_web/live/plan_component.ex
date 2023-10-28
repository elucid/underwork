defmodule UnderworkWeb.PlanComponent do
  use UnderworkWeb, :live_component
  import UnderworkWeb.Helpers

  alias Underwork.Cycles

  def update(%{session: session} = assigns, socket) do
    changeset = Cycles.change_session_plan(session)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
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
