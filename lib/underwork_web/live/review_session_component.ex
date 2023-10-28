defmodule UnderworkWeb.ReviewSessionComponent do
  use UnderworkWeb, :live_component

  alias Underwork.Cycles

  def update(%{session: session} = assigns, socket) do
    changeset = Cycles.change_session_review(session)
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
      |> Cycles.change_session_review(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"session" => params}, socket) do
    session = socket.assigns.session

    case Cycles.review_session(session, params) do
      {:ok, _session} ->
        socket =
          socket
          |> put_flash(:info, "YAY")
          |> push_navigate(to: ~p"/session")

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end
end
