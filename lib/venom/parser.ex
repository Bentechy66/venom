defmodule Venom.Parser do
  @moduledoc """
  This module largely contains functions designed for internal use. You're probably better off using
  the functions defined in `Venom`, unless you need to perform some specific NBT parsing yourself.
  """

  defp parse_unsigned!(data, size) when is_binary(data) do
    <<result::unsigned-size(size), rest::binary>> = data

    {result, rest}
  end

  defp parse_signed!(data, bits) when is_binary(data) do
    <<result::signed-size(bits), rest::binary>> = data

    {result, rest}
  end

  defp parse_fp!(data, bits) when is_binary(data) do
    <<result::float-size(bits), rest::binary>> = data

    {result, rest}
  end

  @doc """
  Parse a tag type from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_tag_type!(<<5, 0xAA, 0xBB>>)
      {5, <<0xAA, 0xBB>>}
  """
  def parse_tag_type!(data) when is_binary(data) do
    {tag, rest} = parse_unsigned!(data, 8)

    if tag > 12 do raise("Illegal NBT tag type") end

    {tag, rest}
  end

  @doc """
  Parse a string from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_string!(<<0, 5, "abcde", 0xAA, 0xBB>>)
      {"abcde", <<0xAA, 0xBB>>}
  """
  def parse_string!(data) when is_binary(data) do
    {length, rest} = parse_unsigned!(data, 16)

    <<string::binary-size(length), rest::binary>> = rest

    {string, rest}
  end

  @doc """
  Parse a byte (8 bits) from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_byte!(<<5, 0xAA, 0xBB>>)
      {5, <<0xAA, 0xBB>>}
  """
  def parse_byte!(data)  when is_binary(data), do: parse_signed!(data, 8)

  @doc """
  Parse a short (16 bits) from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_short!(<<0, 5, 0xAA, 0xBB>>)
      {5, <<0xAA, 0xBB>>}
  """
  def parse_short!(data) when is_binary(data), do: parse_signed!(data, 16)

  @doc """
  Parse an int (32 bits) from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_int!(<<0, 0, 0, 5, 0xAA, 0xBB>>)
      {5, <<0xAA, 0xBB>>}
  """
  def parse_int!(data)   when is_binary(data), do: parse_signed!(data, 32)

  @doc """
  Parse a long (64 bits) from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_long!(<<0, 0, 0, 0, 0, 0, 0, 5, 0xAA, 0xBB>>)
      {5, <<0xAA, 0xBB>>}
  """
  def parse_long!(data)  when is_binary(data), do: parse_signed!(data, 64)

  @doc """
  Parse a float (32 bits) from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_float!(<<25, 25, 25, 25, 0xAA, 0xBB>>)
      {7.914983038854372e-24, <<0xAA, 0xBB>>}
  """
  def parse_float!(data)  when is_binary(data), do: parse_fp!(data, 32)

  @doc """
  Parse a double (64 bits) from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_double!(<<25, 25, 25, 25, 25, 25, 25, 25, 0xAA, 0xBB>>)
      {9.01285756841504e-188, <<0xAA, 0xBB>>}
  """
  def parse_double!(data) when is_binary(data), do: parse_fp!(data, 64)

  defp parse_array!(parsing_function, data) when is_binary(data) do
    {length, data} = parse_signed!(data, 32)

    parse_array_items!(parsing_function, data, length, [])
  end
  defp parse_array_items!(_, data, 0, acc), do: {Enum.reverse(acc), data}
  defp parse_array_items!(parsing_function, data, remaining, acc) do
    {byte, data} = parsing_function.(data)
    acc = [byte | acc]
    parse_array_items!(parsing_function, data, remaining - 1, acc)
  end

  @doc """
  Parse an i32-length-prefixed array of bytes from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_byte_array!(<<0, 0, 0, 4, 1, 2, 3, 4, 0xAA, 0xBB>>)
      {[1, 2, 3, 4], <<0xAA, 0xBB>>}
  """
  def parse_byte_array!(data), do: parse_array!(&parse_byte!/1, data)

  @doc """
  Parse an i32-length-prefixed array of 32-bit signed ints from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_int_array!(<<0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 2, 0xAA, 0xBB>>)
      {[1, 2], <<0xAA, 0xBB>>}
  """
  def parse_int_array!(data),  do: parse_array!(&parse_int!/1 , data)

  @doc """
  Parse an i32-length-prefixed array of 64-bit signed longs from a binary, returning any remaining data.

  ## Examples

      iex> Venom.Parser.parse_long_array!(<<0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0xAA, 0xBB>>)
      {[1, 2], <<0xAA, 0xBB>>}
  """
  def parse_long_array!(data), do: parse_array!(&parse_long!/1, data)

  def parse_list!(data) do
    {tag_type, data} = parse_tag_type!(data)
    {list_len, data} = parse_signed!(data, 32)

    parse_list_items(tag_type, data, list_len, [])
  end
  defp parse_list_items(_,    rest, 0,         acc), do: {acc, rest}
  defp parse_list_items(type, data, remaining, acc) do
    {item, data} = parse_data_of_type!(data, type)
    parse_list_items(type, data, remaining - 1, [item | acc])
  end

  defp parse_compound!(data) when is_binary(data) do
    parse_inner_compound_tags!(data, %{})
  end
  defp parse_inner_compound_tags!(<<0, rest::binary>>, acc), do: {acc, rest}
  defp parse_inner_compound_tags!(data, acc) do
    {{tag_name, tag_data}, rest} = parse_named_tag!(data)
    parse_inner_compound_tags!(rest, Map.put(acc, tag_name, tag_data))
  end

  defp parse_named_tag!(data) when is_binary(data) do
    {tag_type, data} = parse_tag_type!(data)
    {tag_name, data} = parse_string!(data)
    {tag_data, data} = parse_data_of_type!(data, tag_type)

    {{tag_name, tag_data}, data}
  end

  defp parse_data_of_type!(data, type) when is_binary(data) do
    case type do
      1  -> parse_byte!(data)
      2  -> parse_short!(data)
      3  -> parse_int!(data)
      4  -> parse_long!(data)

      5  -> parse_float!(data)
      6  -> parse_double!(data)

      7  -> parse_byte_array!(data)

      8  -> parse_string!(data)

      9  -> parse_list!(data)

      10 -> parse_compound!(data)

      11 -> parse_int_array!(data)
      12 -> parse_long_array!(data)
    end
  end

  @doc """
  Entry-point for parsing a full NBT tag. Ensures a single-keyed compound.
  """
  def parse_root!(data) when is_binary(data) do
    # NBT data is always implicitly inside a compound.

    {{name, data}, rest} = parse_named_tag!(data)

    if byte_size(rest) > 0 do raise "abort: leftover data" end

    parsed = %{}
    Map.put(parsed, name, data)
  end
end
