defmodule KVHttp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("HTTP_PORT") || "4040")
    children = [
      # Starts a worker by calling: KVHttp.Worker.start_link(arg)
      # {KVHttp.Worker, arg}
      Plug.Adapters.Cowboy.child_spec(
        scheme: :http,
        plug: KVHttp.Router,
        options: [port: port]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KVHttp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
