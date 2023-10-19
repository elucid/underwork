defmodule Underwork.CyclesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Underwork.Cycles` context.
  """

  @doc """
  Generate a session.
  """
  def session_fixture(attrs \\ %{}) do
    configure_attrs =
      Map.merge(
        %{
          target_cycles: 2,
          start_at: DateTime.utc_now() |> DateTime.truncate(:second)
        },
        Map.take(Enum.into(attrs, %{}), [:target_cycles, :start_at])
      )

    plan_attrs =
      Map.merge(
        %{accomplish: "some accomplish"},
        Map.take(
          Enum.into(attrs, %{}),
          [
            :accomplish,
            :complete,
            :distractions,
            :important,
            :measureable,
            :noteworthy
          ]
        )
      )

    session = %Underwork.Cycles.Session{}

    with {:ok, session} <- Underwork.Cycles.configure_session(session, configure_attrs),
         {:ok, session} <- Underwork.Cycles.plan_session(session, plan_attrs) do
      session
    end
  end

  @doc """
  Generate a cycle.
  """
  def cycle_fixture(attrs \\ %{}) do
    {:ok, cycle} =
      attrs
      |> Enum.into(%{
        accomplish: "some accomplish",
        energy: 42,
        hazards: "some hazards",
        morale: 42,
        started: "some started"
      })
      |> Underwork.Cycles.create_cycle()

    cycle
  end
end
