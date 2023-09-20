defmodule Underwork.CyclesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Underwork.Cycles` context.
  """

  @doc """
  Generate a session.
  """
  def session_fixture(attrs \\ %{}) do
    {:ok, session} =
      attrs
      |> Enum.into(%{
        accomplish: "some accomplish",
        complete: "some complete",
        distractions: "some distractions",
        important: "some important",
        measurable: "some measurable",
        noteworthy: "some noteworthy"
      })
      |> Underwork.Cycles.create_session()

    session
  end
end