defmodule Venom do
  @moduledoc """
  Venom - Elixir NBT parser.
  """

  @doc """
  Decode a binary representing NBT data.

  ## Examples

      iex> Venom.decode_nbt!(<<10, 0, 11, 104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, 8, 0, 4, 110, 97, 109, 101, 0, 9, 66, 97, 110, 97, 110, 114, 97, 109, 97, 0>>)
      %{"hello world" => %{"name" => "Bananrama"}}

  """
  def decode_nbt!(data) when is_binary(data) do
    data = case data do
      <<0x1f, 0x8b, _::binary>> -> :zlib.gunzip(data)
      _ -> data
    end

    Venom.Parser.parse_root!(data)
  end

  def encode_nbt!(data) do
    Venom.Encoder.encode!(data)
  end
end
