defmodule Hangman.GameTest do
  use ExUnit.Case
  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()

    assert is_struct(game, Game)
    assert game.turns_left == 7
    assert game.state == :initializing
    assert length(game.letters) > 0
  end

  test "new_game returns only lowercase letters" do
    game = Game.new_game()

    assert game.letters |> Enum.all?(&String.match?(&1, ~r/[a-z]/))
  end

  test "state isn't changed for :won or : lost game" do
    for state <- [:won, :lost] do
      game = Game.new_game() |> Map.put(:state, state)
      assert {^game, _tally} = Game.make_move(game, "x")
    end
  end

  test "first occurrence of letter is not already used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.state != :already_used
  end

  test "second occurrence of letter is already used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.state != :already_used
    {game, _tally} = Game.make_move(game, "x")
    assert game.state == :already_used
  end

  test "a good guess is recognized" do
    game = Game.new_game("wibble")
    {game, _tally} = Game.make_move(game, "w")
    assert game.state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game" do
    game = Game.new_game("wibble")
    {game, _tally} = Game.make_move(game, "w")
    assert game.state == :good_guess
    assert game.turns_left == 7
    {game, _tally} = Game.make_move(game, "i")
    assert game.state == :good_guess
    assert game.turns_left == 7
    {game, _tally} = Game.make_move(game, "b")
    assert game.state == :good_guess
    assert game.turns_left == 7
    {game, _tally} = Game.make_move(game, "l")
    assert game.state == :good_guess
    assert game.turns_left == 7
    {game, _tally} = Game.make_move(game, "e")
    assert game.state == :won
    assert game.turns_left == 7
  end

  test "bad guess is recognized" do
    game = Game.new_game("wibble")
    {game, _tally} = Game.make_move(game, "x")
    assert game.state == :bad_guess
    assert game.turns_left == 6
  end

  test "7 bad guesses result in lost game" do
    game = Game.new_game("w")
    {game, _tally} = Game.make_move(game, "a")
    assert game.state == :bad_guess
    assert game.turns_left == 6
    {game, _tally} = Game.make_move(game, "b")
    assert game.state == :bad_guess
    assert game.turns_left == 5
    {game, _tally} = Game.make_move(game, "c")
    assert game.state == :bad_guess
    assert game.turns_left == 4
    {game, _tally} = Game.make_move(game, "d")
    assert game.state == :bad_guess
    assert game.turns_left == 3
    {game, _tally} = Game.make_move(game, "e")
    assert game.state == :bad_guess
    assert game.turns_left == 2
    {game, _tally} = Game.make_move(game, "f")
    assert game.state == :bad_guess
    assert game.turns_left == 1
    {game, _tally} = Game.make_move(game, "g")
    assert game.state == :lost
  end
end
