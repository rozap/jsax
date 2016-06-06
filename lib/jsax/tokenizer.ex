defmodule Jsax.Tokenizer do

  defmacro change(token, opts \\ []) do
    push  = Keyword.get(opts, :push, nil)
    pop   = Keyword.get(opts, :pop, nil)
    emit  = Keyword.get(opts, :emit, nil)


    mode_matcher = case pop do
      nil -> quote do: stack
      {mode, :quiet} -> quote do: [unquote(mode) | stack]
      mode -> quote do: [unquote(mode) | stack]
    end

    pusher = case push do
      {push_tok, :quiet} -> quote do: [unquote(push_tok) | stack]
      nil                -> quote do: stack
      _                  -> quote do: [unquote(push) | stack]
    end

    emitter = case emit do
      nil ->
        case {push, pop} do
          {nil, nil} -> :quiet
          {_, {_, :quiet}} -> :quiet
          {{_, :quiet}, _} -> :quiet
          {_, nil} -> quote do: unquote(push)
          {_, pop} -> quote do: {unquote(pop), acc}
        end
      _ -> emit
    end

    IO.puts "    "
    IO.puts "#{inspect push} #{inspect pop} #{inspect pusher} #{inspect emitter}"

    quote do
      def read(unquote(token) <> rest, unquote(mode_matcher), acc) do
        case {unquote(push), unquote(pop)} do
          {nil, nil}  -> {:ok, :quiet, rest, stack, acc}
          _           -> {:ok, unquote(emitter), rest, unquote(pusher), ""}
        end
      end
    end
  end
end