defmodule Clio.Router do
  use Clio.Web, :router

  pipeline :basic_auth do
    plug BasicAuth, realm: "Logplex Endpoint", username: System.get_env("BASIC_AUTH_USER"), password: System.get_env("BASIC_AUTH_PASSWORD")
  end

  pipeline :api do
    plug :basic_auth

    plug :accepts, ["json"]
  end

  pipeline :logplex do
    plug :accepts, ["application/logplex-1"]
  end

  pipeline :browser do
    plug :basic_auth

    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/logplex", Clio do
    pipe_through :basic_auth
    pipe_through :logplex
    post "/new", LogplexController, :create
  end

  scope "/", Clio do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Clio do
  #   pipe_through :api
  # end
end
