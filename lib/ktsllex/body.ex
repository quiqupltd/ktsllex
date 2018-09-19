defmodule Ktsllex.Body do
  @moduledoc """
  Helpers to extract API resposes
  """

  require Logger

  @spec extract({:error, HTTPoison.Error.t()} | {:ok, HTTPoison.Response.t()}) :: any()
  def extract({:ok, %HTTPoison.Response{body: body, headers: headers}}) do
    case gzipped(headers) do
      true -> :zlib.gunzip(body)
      false -> body
    end
  end

  def extract({:error, %HTTPoison.Error{reason: reason}}) do
    Logger.error("#{__MODULE__} failed:#{inspect(reason)}")
    :error
  end

  defp gzipped(headers) do
    headers
    |> Enum.any?(fn kv ->
      case kv do
        {"Content-Encoding", "gzip"} -> true
        _ -> false
      end
    end)
  end
end
