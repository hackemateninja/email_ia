defmodule EmailIaWeb.Router do
  use EmailIaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EmailIaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EmailIaWeb do
    pipe_through [:browser, EmailIaWeb.AuthPlug]

    get "/", AuthController, :signin

    live_session :current_route, on_mount: [EmailIaWeb.CurrentRoute, EmailIaWeb.AuthHook] do
      scope "/dashboard" do
        live "/", DashboardLive
        live "/emails", EmailsLive
        live "/emails/:id", EmailLive, :show
        live "/categories", CategoriesLive
        live "/categories/:id", CategoryLive, :show
        live "/accounts", AccountsLive
      end
    end
  end

  # scope "/", EmailIaWeb do
  #   pipe_through [:browser, EmailIaWeb.AuthPlug]

  #   # Protected routes that require authentication
  #   # Add any protected routes here
  #   # live_session :current_route, on_mount: [EmailIaWeb.CurrentRoute] do
  #   # scope "/dashboard" do
  #   #   live "/", DashboardLive
  #   #   live "/emails", EmailsLive
  #   #   live "/emails/:id", EmailLive, :show
  #   #   live "/categories", CategoriesLive
  #   #   live "/categories/:id", CategoryLive, :show
  #   #   live "/accounts", AccountsLive
  #   # end
  #   # end
  # end

  scope "/auth", EmailIaWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", EmailIaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:email_ia, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EmailIaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
