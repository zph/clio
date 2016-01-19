defmodule Clio.LogplexController do
  use Clio.Web, :controller

  # def create(conn, %{"body" => body } = params) do
    # Clio.Endpoint.broadcast! "rooms:lobby", "new_msg", %{body: body}
    # json conn, %{status: :ok}
  # end

  def create(conn, _params) do
    {_status, body, _opts} = read_body(conn)

    lines = Syslog.msg_to_parsed_lines(body)

    metrics = Enum.filter(lines, fn(x) -> x.structured_data.type == :metric end)
    heroku_lines = Enum.filter(lines, fn(x) -> x.structured_data.type == :other end)

    Enum.each(metrics, fn(x) -> Clio.Endpoint.broadcast! "rooms:lobby", "metrics", %{body: x.structured_data.text} end)
    Enum.each(heroku_lines, fn(x) -> Clio.Endpoint.broadcast! "rooms:lobby", "log_lines", %{body: x.structured_data.text} end)
    send_resp(conn, 201, "")
  end
end
