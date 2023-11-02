defmodule UnderworkWeb.SetupLive do
  use UnderworkWeb, :live_view

  alias Underwork.Cycles

  def mount(_params, _session, socket) do
    session = Cycles.current_session_for_user()
    changeset = Cycles.change_session_cycles(session)

    socket =
      socket
      |> assign(:session, session)
      |> assign(:start_at, "")
      |> assign_form(changeset)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="setup" phx-hook="TimezoneOffset">
      <.header>
        <:subtitle>Use this form to manage session records in your database.</:subtitle>
      </.header>

      <.simple_form for={@form} id="session-form" phx-change="validate" phx-submit="save">
        <div>
          <label>Cycles</label>
          <.button type="button" phx-click="decrement_cycles" phx-disable={false}>
            -
          </.button>
          <span><%= Ecto.Changeset.get_field(@form.source, :target_cycles) %></span>
          <.button type="button" phx-click="increment_cycles" phx-disable={false}>
            +
          </.button>
        </div>
        <div>
          <label>Start at</label>
          <.button>-</.button>
          <span><%= @start_at %></span>
          <.button>+</.button>
          <.input field={@form[:start_at]} type="hidden" />
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Session</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("timezone_offset", offset, socket) do
    start_at = nearest_10_minutes(DateTime.utc_now())
    changeset = Cycles.change_session_cycles(socket.assigns.session, %{start_at: start_at})

    socket =
      socket
      |> assign(:timezone_offset, offset)
      |> assign(:start_at, format_time(start_at, offset))
      |> assign_form(changeset)

    {:noreply, socket}
  end

  def handle_event("validate", %{"session" => session_params}, socket) do
    changeset =
      socket.assigns.session
      |> Cycles.change_session_cycles(session_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("increment_cycles", _, socket) do
    target_cycles = Ecto.Changeset.get_field(socket.assigns.form.source, :target_cycles)

    # TODO move this into the changeset
    new_cycles = min(target_cycles + 1, 18)

    changeset =
      socket.assigns.session
      |> Cycles.change_session_cycles(%{target_cycles: new_cycles})
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("decrement_cycles", _, socket) do
    target_cycles = Ecto.Changeset.get_field(socket.assigns.form.source, :target_cycles)

    # TODO move this into the changeset
    new_cycles = max(target_cycles - 1, 2)

    changeset =
      socket.assigns.session
      |> Cycles.change_session_cycles(%{target_cycles: new_cycles})
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"session" => session_params}, socket) do
    case Cycles.configure_session(socket.assigns.session, session_params) do
      {:ok, session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Session updated successfully")
         |> push_navigate(to: ~p"/cycles")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp format_time(utc_time, timezone_offset_minutes) do
    DateTime.add(utc_time, -timezone_offset_minutes * 60, :second)
    |> Timex.format!("%l:%M %p", :strftime)
  end

  defp nearest_10_minutes(date_time) do
    seconds = DateTime.to_unix(date_time)
    remainder = rem(seconds, 600)

    rounded_seconds =
      if remainder < 300, do: seconds - remainder, else: seconds + (600 - remainder)

    DateTime.from_unix!(rounded_seconds)
  end
end
