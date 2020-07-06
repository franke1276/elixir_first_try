defmodule KVHttp.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  # TODO: add routes!

    put "/buckets/:bucket/:key/:value" do
    {:ok, _body, conn} = read_body(conn)

    bucket = conn.path_params["bucket"]
    key = conn.path_params["key"]
    value = conn.path_params["value"]
    Logger.info("PUT bucket: #{bucket} #{key} #{value}")

    case KV.Router.route(bucket, KV.Registry, :lookup, [KV.Registry, bucket]) do
      {:ok, pid} ->
        KV.Bucket.put(pid, key, value)
        send_resp(conn, 201, Poison.encode!(%{message: "OK PUT"}))

      _ ->
        send_resp(conn, 500, Poison.encode!(%{message: "error"}))
    end
  end

  get "/buckets/:bucket/:key" do
    {:ok, _body, conn} = read_body(conn)

    bucket = conn.path_params["bucket"]
    key = conn.path_params["key"]
    Logger.info("GET bucket: #{bucket} #{key}")

    with {:ok, pid} <- KV.Router.route(bucket, KV.Registry, :lookup, [KV.Registry, bucket]),
         {:ok, value} <- KV.Bucket.get(pid, key)
      do
        send_resp(conn, 200, Poison.encode!(%{value: value}))
      else
        err ->
          Logger.warn("bucket: #{bucket} #{key}")
          IO.inspect(err)
          send_resp(conn, 404, Poison.encode!(%{message: "not found"}))
      end
  end

  put "/buckets/:bucket" do
    {:ok, _body, conn} = read_body(conn)

    bucket = conn.path_params["bucket"]
    Logger.info("create bucket: #{bucket}")

    case KV.Router.route(bucket, KV.Registry, :create, [KV.Registry, bucket]) do
      pid when is_pid(pid) -> send_resp(conn, 201, Poison.encode!(%{message: "created"}))
      _ -> send_resp(conn, 500, Poison.encode!(%{message: "error"}))
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
