defmodule Hangman.Game do

  defstruct [
    turns_left: 7,
    state: :initializing,
    letters: [],
    used: MapSet.new(),
    word: "",
  ]

  def new_game(word) do
    %Hangman.Game{
      word: word,
      letters: word |> String.codepoints(),
    }
  end

  def new_game() do
    Dictionary.get_random_word()
    |> new_game()
  end

  def make_move(%__struct__{state: state} = game, _guess) when state in [:won, :lost] do
    game
    |> return_with_tally()
  end

  def make_move(game, guess) do
    accept_move(game, guess, MapSet.member?(game.used, guess))
    |> return_with_tally()
  end

  defp return_with_tally(game), do: {game, tally(game)}

  def tally(game) when game.state in [:won, :lost] do
    %{
      state: game.state,
      letters: game.letters |> reveal_guessed(game.used),
      used: game.used,
      word: game.word,
    }
  end

  def tally(game) do
    %{
      state: game.state,
      turns_left: game.turns_left,
      letters: game.letters |> reveal_guessed(game.used),
      used: game.used,
    }
  end

  defp accept_move(game, _guess, _already_guessed = true) do
    Map.put(game, :state, :already_used)
  end

  defp accept_move(game, guess, _already_guessed) do
    Map.put(game, :used, MapSet.put(game.used, guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end

  defp score_guess(game, _good_guess = true) do
    new_state = MapSet.new(game.letters)
    |> MapSet.subset?(game.used)
    |> maybe_won()

    Map.put(game, :state, new_state)
  end

  defp score_guess(%{turns_left: 1} = game, _bad_guess) do
    Map.put(game, :state, :lost)
  end

  defp score_guess(%{turns_left: turns_left} = game, _bad_guess) do
    %{game | state: :bad_guess, turns_left: turns_left - 1}
  end

  defp maybe_won(true), do: :won
  defp maybe_won(_), do: :good_guess

  defp reveal_guessed(letters, used) do
    letters
    |> Enum.map(fn letter -> reveal_letter(letter, MapSet.member?(used, letter)) end)
  end

  defp reveal_letter(letter, _in_word = true), do: letter
  defp reveal_letter(_letter, _not_in_word), do: "_"
end
