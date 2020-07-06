defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end

  test "store values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "delete value by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil
    KV.Bucket.put(bucket, "milk", 3)

    assert KV.Bucket.delete(bucket, "milk") == 3
    assert KV.Bucket.get(bucket, "milk") == nil
  end
end
