defmodule VenomTest do
  use ExUnit.Case
  doctest Venom
  doctest Venom.Parser

  test "Basic test" do
    assert Venom.decode_nbt!(File.read!(<<__DIR__, "/hello_world.nbt">>)) == %{"hello world" => %{"name" => "Bananrama"}}
  end

  test "Big test" do
    big_data = File.read!(<<__DIR__, "/bigtest.nbt">>)

    assert %{
      "Level" => %{
        "byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...))" => [
          0, 62, 34, 16, 8, 10, 22, 44, 76, 18, 70, 32, 4, 86, 78, 80, 92, 14, 46, 88, 40, 2, 74, 56, 48, 50, 62, 84, 16, 58, 10, 72, 44, 26, 18, 20, 32, 54, 86, 28, 80, 42, 14, 96, 88, 90, 2, 24, 56 | _
        ],
        "byteTest" => 127,
        "doubleTest" => 0.4931287132182315,
        "floatTest" => 0.4982314705848694,
        "intTest" => 2147483647,
        "listTest (compound)" => [
          %{"created-on" => 1264099775885, "name" => "Compound tag #1"},
          %{"created-on" => 1264099775885, "name" => "Compound tag #0"}
        ],
        "listTest (long)" => [15, 14, 13, 12, 11],
        "longTest" => 9223372036854775807,
        "nested compound test" => %{
          "egg" => %{
            "name" => "Eggbert", "value" => 0.5
          },
          "ham" => %{
            "name" => "Hampus", "value" => 0.75
            }
          },
          "shortTest" => 32767,
          "stringTest" => "HELLO WORLD THIS IS A TEST STRING ÅÄÖ!"
      }
    } = Venom.decode_nbt!(big_data)
  end
end
