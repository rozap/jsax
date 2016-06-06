defmodule JsaxTest do
  use ExUnit.Case
  doctest Jsax

  def string_res(str) do
    Stream.resource(
      fn -> str end,
      fn
        <<head::binary-size(1), rest::binary>> -> {[head], rest}
        _ -> {:halt, ""}
      end,
      fn _ -> :ok end
    )
  end

  test "simple object" do
    result = """
      {"foo": "bar"}
    """
    |> string_res
    |> Jsax.tokenize!
    |> Enum.into([])

    assert result == [
      :object_start,
      {:key, "foo"},
      {:value, "bar"},
      :object_end
    ]

  end

  test "nested object" do
    result = """
      {"foo": {"bar": "baz"}}
    """
    |> string_res
    |> Jsax.tokenize!
    |> Enum.into([])

    assert result == [
      :object_start,
      {:key, "foo"},
      :object_start,
      {:key, "bar"},
      {:value, "baz"},
      :object_end
    ]
  end


end
