defmodule UnderworkWeb.SetupLive do
  use UnderworkWeb, :live_view

  alias Underwork.Cycles
  alias Underwork.Cycles.Session

  def mount(_params, _session, socket) do
    session = Cycles.current_session_for_user()
    target_cycles = session.target_cycles
    start_at = session.start_at || nearest_10_minutes(DateTime.utc_now())
    offset = 0

    socket =
      socket
      |> assign(:session, session)
      |> assign(:target_cycles, target_cycles)
      |> assign(:start_at, start_at)
      |> assign(:offset, offset)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="setup" phx-hook="TimezoneOffset">
      <.header>
        <:subtitle>Use this form to manage session records in your database.</:subtitle>
      </.header>

      <form id="session-form" phx-submit="save">
        <div>
          <label>Cycles</label>
          <.button type="button" phx-click="decrement_cycles" phx-disable={at_min(@target_cycles)}>
            -
          </.button>
          <span><%= @target_cycles %></span>
          <.button type="button" phx-click="increment_cycles" phx-disable={at_max(@target_cycles)}>
            +
          </.button>
        </div>
        <div>
          <label>Start at</label>
          <.button type="button">-</.button>
          <span><%= format_time(@start_at, @offset) %></span>
          <.button type="button">+</.button>
        </div>
          <.button phx-disable-with="Saving...">Save Session</.button>
      </form>
    </div>
    """
  end

  def handle_event("timezone_offset", offset, socket) do
    socket =
      socket
      |> assign(:timezone_offset, offset)

    {:noreply, socket}
  end

  def handle_event("increment_cycles", _, socket) do
    new_cycles = min(socket.assigns.target_cycles + 1, 18)

    {:noreply, assign(socket, :target_cycles, new_cycles)}
  end

  def handle_event("decrement_cycles", _, socket) do
    new_cycles = max(socket.assigns.target_cycles - 1, 2)

    {:noreply, assign(socket, :target_cycles, new_cycles)}
  end

  def handle_event("save", _, socket) do
    session_params = %{target_cycles: socket.assigns.target_cycles, start_at: socket.assigns.start_at}
    case Cycles.configure_session(socket.assigns.session, session_params) do
      {:ok, _session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Session updated successfully")
         |> push_navigate(to: ~p"/cycles")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "An unexpected error happened")}
    end
  end

  defp at_max(target_cycles) do
    target_cycles == Session.max_cycles
  end

  defp at_min(target_cycles) do
    target_cycles == Session.min_cycles
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
