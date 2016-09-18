defmodule Auth.Router do
  use Auth.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

   scope "/auth", Auth do
     pipe_through :api

     post "/email", AuthController, :email
     post "/login", AuthController, :login
   end
end
