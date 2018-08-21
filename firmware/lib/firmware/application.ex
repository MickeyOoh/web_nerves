defmodule Firmware.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  @target Mix.Project.config()[:target]
  use Application

  import Supervisor.Spec, warn: false
  @interface Application.get_env(:firmware, :interface, :wlan0)

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Firmware.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children("host") do
    [
      # Starts a worker by calling: Firmware.Worker.start_link(arg)
      # {Firmware.Worker, arg},
    ]
  end

  def children(_target) do
    [
      supervisor(Phoenix.PubSub.PG2, [Nerves.PubSub, [poolsize: 1]]),
      worker(Task, [fn -> start_network() end], restart: :transient)
    ]
  end

  def start_network do 
    IO.puts to_string(@interface)
    Nerves.Network.setup(to_string(@interface))
    #settings = Nerves.NetworkInterface.settings(to_string(@interface))
    #IO.inspect settings
  end
end
