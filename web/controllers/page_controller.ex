defmodule Clio.PageController do
  use Clio.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
