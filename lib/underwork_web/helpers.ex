defmodule UnderworkWeb.Helpers do
  use Phoenix.VerifiedRoutes,
    endpoint: UnderworkWeb.Endpoint,
    router: UnderworkWeb.Router

  def next_cycle_path(session, cycle) do
    cond do
      cycle.state == "planning" ->
        ~p"/sessions/#{session.id}/cycle/#{cycle.id}/plan"
      cycle.state == "working" ->
        ~p"/sessions/#{session.id}/cycle/#{cycle.id}/work"
      cycle.state == "reviewing" ->
        ~p"/sessions/#{session.id}/cycle/#{cycle.id}/review"
      cycle == nil ->
        ~p"/sessions/#{session.id}/review"
    end
  end
end
