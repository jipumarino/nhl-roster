#!/usr/bin/env ruby

require "json"
require "colorize"

team_name = ARGV[0..-1].join(" ")
if team_name.empty?
  puts "No team name was passed"
  exit
end

all_data = JSON.parse(File.read("nhl_data.json"))
team_data = all_data.detect{|t| t["name"].downcase == team_name.downcase}

if team_data.nil?
  puts "No team found with name '#{team_name}'"
  exit
end

players = team_data["players"]

players.shuffle!

correct_answers = []
wrong_answers = []

puts "\nPlaying with the #{team_data['city']} #{team_data['name']}!\n"

players.each do |player|
  number = player["number"]
  correct_last_name = player["last_name"]

  puts "\nPlayer number: #{number}"
  input_last_name = STDIN.gets

  break if input_last_name.nil?

  input_last_name.strip!

  label = "#{'%2d' % number} #{correct_last_name}"

  if input_last_name.downcase == correct_last_name.downcase
    puts "Correct!".green
    correct_answers << label
  else
    puts "Wrong, it was #{correct_last_name}".red
    wrong_answers << label
  end
end

puts "\n\nCorrect (#{correct_answers.size}):".green
correct_answers.each{|a| puts a.green}

puts "\nWrong (#{wrong_answers.size}):".red
wrong_answers.each{|a| puts a.red}

