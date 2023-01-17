class GamesController < ApplicationController
  def new
    # display grid and form
    characters = Array('A'..'Z')
    @letters = characters.sample(10).join(' ')
  end

  def score
    # the above form will be submitted by post to score
    @guess = params[:word]
  end
end

require 'open-uri'
require 'json'

def included?(guess, grid)
  guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
end

def compute_score(attempt, time_taken)
  time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
  result = { time: end_time - start_time }

  score_and_message = score_and_message(attempt, grid, result[:time])
  result[:score] = score_and_message.first
  result[:message] = score_and_message.last

  result
end

def score_and_message(attempt, grid, time)
  if included?(attempt.upcase, grid)
    if english_word?(attempt)
      score = compute_score(attempt, time)
      [score, 'well done']
    else
      [0, 'not an english word']
    end
  else
    [0, 'not in the grid']
  end
end

def english_word?(word)
  response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
  json = JSON.parse(response.read)
  return json['found']
end
