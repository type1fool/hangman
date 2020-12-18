defmodule Hangman.Server do
  use GenServer

  alias Hangman.Game

  @module_name __MODULE__
  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def child_spec(_args) do
    %{
      id: @module_name,
      start: {@module_name, :start_link, []}
    }
  end

  @impl true
  def init(_) do
    {:ok, Game.new_game()}
  end

  @impl true
  def handle_call({:make_move, guess}, _from, game) do
    {game, tally} = Game.make_move(game, guess)
    {:reply, tally, game}
  end

  @impl true
  def handle_call({:tally}, _from, game) do
    {:reply, Game.tally(game), game}
  end
end
