defmodule UnderworkWeb.ReviewCycleComponent do
  use UnderworkWeb, :live_component

  alias Underwork.Cycles

  def update(%{cycle: cycle} = assigns, socket) do
    changeset = Cycles.change_cycle_plan(cycle)
    form = to_form(changeset)

    socket =
      socket
      |> assign(:cycle, cycle)
      |> assign(:form, form)

    {:ok, socket}
  end

  def handle_event("validate", %{"cycle" => params}, socket) do
    changes = Map.merge(string_keys(socket.assigns.form.source.changes), params)

    changeset =
      socket.assigns.cycle
      |> Cycles.change_cycle_review(changes)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("set_target", %{"target" => target} = params, socket) do
    changes = Map.merge(string_keys(socket.assigns.form.source.changes), params)

    changeset =
      socket.assigns.cycle
      |> Cycles.change_cycle_target(changes)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"cycle" => params}, %{assigns: %{cycle: cycle}} = socket) do
    changes = Map.merge(string_keys(socket.assigns.form.source.changes), params)

    case Cycles.review_cycle(cycle, changes) do
      {:ok, _cycle} ->
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

  def target_button(%{value: value, label: label, form: form, "phx-target": phx_target} = assigns) do
    ~H"""
    <.button type="button"
      phx-click="set_target" phx-value-target={value} phx-target={phx_target}
      class={if Phoenix.HTML.Form.input_value(form, :target) == value, do: "bg-zinc-500", else: "bg-zinc-200"}
      phx-prevent-default><%= label %></.button>
    """
  end

  def string_keys(map) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
