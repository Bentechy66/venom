# Venom

**An [NBT](https://wiki.vg/NBT) decoder written in pure Elixir**

## Installation

First, add Venom to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:venom, "~> 0.1.0"}
  ]
end
```

Then, update your dependencies:

```
$ mix deps.get
```

## Usage

```elixir
iex> Venom.decode_nbt!(File.read!("hello_world.nbt"))
      %{"hello world" => %{"name" => "Bananrama"}}
```

## Coming Soon(?)
 - Encoding support

The docs can be found at <https://hexdocs.pm/venom>.

