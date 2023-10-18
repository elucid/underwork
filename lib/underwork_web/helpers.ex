defmodule UnderworkWeb.Helpers do
  use Phoenix.VerifiedRoutes,
    endpoint: UnderworkWeb.Endpoint,
    router: UnderworkWeb.Router

  alias Underwork.Repo

  def next_cycle_path(session) do
    session = Repo.preload(session, :cycles)
    last_cycle = List.last(session.cycles)

    cond do
      session.cycles == [] ->
        ~p"/sessions/#{session.id}/cycle/new"
      last_cycle.state != "reviewed" ->
        ~p"/sessions/#{session.id}/cycle/#{last_cycle.id}"
      length(session.cycles) < session.target_cycles ->
        ~p"/sessions/#{session.id}/cycle/new"
      true ->
        ~p"/sessions/#{session.id}/review"
    end
  end
end
