defmodule Ktsllex.FileJson do
  @moduledoc """
  Wrapper around File.read to convert file to json
  """
  def read!(filename) do
    with {:ok, body} <- File.read(filename),
         {:ok, json} <- Poison.decode(body) do
      json
    end
  end
end
