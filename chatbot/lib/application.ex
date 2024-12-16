defmodule Chatbot.Application do
  use Application

  @moduledoc """
  Moduł startowy aplikacji Chatbot.
  """

  @debug false

  def start(_type, _args) do
    children = []

    opts = [strategy: :one_for_one, name: Chatbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Sprawdza, czy debugowanie jest włączone.
  """
  def debug? do
    @debug
  end
end

