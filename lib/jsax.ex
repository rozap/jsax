defmodule Jsax do
  import Jsax.Tokenizer

  # @tokens [
  #   {"[", :array_start},
  #   {"]", :array_end},
  #   {"{", :object_start},
  #   {"}", :object_end},
  #   {":", :colon},
  #   {",", :comma},
  #   {"\"", :string},
  #   {"\\", :ex_string},
  #   {"true", :true},
  #   {"false", :false}
  # ]

  # on a token
  #   - can put the mode and acc on the stack
  #     - without acc
  #       - push: :.
  #       - push:
  #   - can pop the mode and acc off the stack
  #     - can suppress it
  #       - pop: {:., :quiet}


  change "[", push: :array_start
  change "]", pop: :array_end
  change "{", push: :object_start
  change "}", pop: :object_start, emit: :object_end
  change ":", push: {:colon, :quiet}

  change "\"", pop: :value
  change "\"", push: :value, pop: {:colon, :quiet}

  change "\"", pop: :key
  change "\"", push: {:key, :quiet}


  def read(<<head::binary-size(1), rest::binary>>, stack, acc) do
    {:ok, :quiet, rest, stack, acc <> head}
  end

  def tokenize!(stream) do
    Stream.transform(
      stream,
      {"", [], ""},
      fn chunk, {buf, stack, acc} ->
        case read(buf <> chunk, stack, acc) do
          {:ok, :quiet, new_buf, new_stack, acc} ->
            {[], {new_buf, new_stack, acc}}
          {:ok, event, new_buf, new_stack, acc} ->
            {[event], {new_buf, new_stack, acc}}
          {:error, reason} ->
            {:halt, reason}
        end
      end)
  end
end
