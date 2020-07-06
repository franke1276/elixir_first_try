defmodule KVHttpTest do
  use ExUnit.Case
  doctest KVHttp

  test "greets the world" do
    assert KVHttp.hello() == :world
  end
end
