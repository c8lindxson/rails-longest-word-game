require 'net/http'
require 'json'

class GamesController < ApplicationController
  def new
    alphabet = ('a'..'z').to_a
    @letters = Array.new(10) { alphabet.sample }
    session[:letters] = @letters.map(&:downcase)
  end

  def score
    word = params[:word].gsub(/[^A-Za-z]/, '').downcase
    @letters = session[:letters].map(&:downcase)
    letters_match = word.chars.all? { |letter| @letters.include?(letter) }

    if letters_match
      if valid_word?(word)
        @message = "Congratulations! '#{word}' is a valid word."
        @score = word.length
      else
        @message = "Sorry, '#{word}' is not a valid English word."
        @score = 0
      end
    else
      @message = "Sorry, '#{word}' can't be built from the given letters."
      @score = 0
    end
  end

  private

  def valid_word?(word)
    uri = URI.parse("https://wagon-dictionary.herokuapp.com/#{word}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10 # Increase the timeout value (in seconds) as needed
    http.read_timeout = 10 # Increase the timeout value (in seconds) as needed
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response_body = JSON.parse(response.body)
    response_body['found']
  end
end
