defmodule UnderworkWeb.Router do
  use UnderworkWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UnderworkWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UnderworkWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/session", SetupLive

    live "/sessions", SessionLive.Index, :index
    live "/sessions/new", SessionLive.Index, :new
    live "/sessions/:id/edit", SessionLive.Index, :edit

    # TODO: this particular LiveView won't do anything--it will just
    # navigate to plan/work/review depending on the state of the session
    live "/sessions/:id", SessionLive.Show, :show
    live "/sessions/:id/show/edit", SessionLive.Show, :edit

    live "/sessions/:id/plan", SessionLive.PlanSession, :plan
    live "/sessions/:id/review", SessionLive.ReviewSession, :review

    # TODO: this particular LiveView won't do anything--it will just
    # navigate to plan/work/review depending on the state of the cycle
    live "/sessions/:session_id/cycle/:id", SessionLive.Cycle, :show

    live "/sessions/:session_id/cycle/:id/plan", SessionLive.PlanCycle, :plan
    live "/sessions/:session_id/cycle/:id/work", SessionLive.Work, :work
    live "/sessions/:session_id/cycle/:id/review", SessionLive.ReviewCycle, :review
  end

  # Other scopes may use custom stacks.
  # scope "/api", UnderworkWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:underwork, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: UnderworkWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
