defmodule MotorcycleAdvisorWeb.Router do
  use MotorcycleAdvisorWeb, :router
  import Phoenix.LiveView.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MotorcycleAdvisorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin_auth do
    plug MotorcycleAdvisorWeb.Plugs.BasicAuth
  end

  pipeline :api_auth do
    plug MotorcycleAdvisorWeb.Plugs.RequireAuthenticatedApiUser
  end

  scope "/api", MotorcycleAdvisorWeb do
    pipe_through :api

    resources "/motorcycles", MotorcycleController, only: [:index, :show]

    post "/quiz/match", QuizController, :match
    get "/quiz/questions", QuizController, :questions
  end

  scope "/api/auth", MotorcycleAdvisorWeb do
    pipe_through :api

    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  scope "/api/auth", MotorcycleAdvisorWeb do
    pipe_through [:api, :api_auth]

    get "/me", AuthController, :me
    delete "/logout", AuthController, :logout
  end

  scope "/api/garage", MotorcycleAdvisorWeb do
    pipe_through [:api, :api_auth]

    resources "/bikes", GarageBikeController, except: [:new, :edit]
    get "/bikes/:garage_bike_id/summary", GarageBikeController, :summary
    get "/bikes/:garage_bike_id/expenses", GarageExpenseController, :index
    post "/bikes/:garage_bike_id/expenses", GarageExpenseController, :create
    patch "/expenses/:id", GarageExpenseController, :update
    put "/expenses/:id", GarageExpenseController, :update
    delete "/expenses/:id", GarageExpenseController, :delete
    get "/summary", GarageStatsController, :summary
  end

  scope "/admin", MotorcycleAdvisorWeb do
    pipe_through [:browser, :admin_auth]

    live_session :admin, root_layout: {MotorcycleAdvisorWeb.Layouts, :root} do
      live "/", Admin.DashboardLive
      live "/motorcycles", Admin.Motorcycles.IndexLive
      live "/motorcycles/new", Admin.Motorcycles.FormLive, :new
      live "/motorcycles/:id/edit", Admin.Motorcycles.FormLive, :edit
      live "/motorcycles/import", Admin.Motorcycles.ImportLive
      live "/quiz", Admin.Quiz.IndexLive
      live "/quiz/new", Admin.Quiz.FormLive, :new
      live "/quiz/:id/edit", Admin.Quiz.FormLive, :edit
      live "/simulator", Admin.SimulatorLive
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:motorcycle_advisor, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: MotorcycleAdvisorWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
