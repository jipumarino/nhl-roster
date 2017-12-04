require "sinatra"
require "sinatra/reloader" if development?
require "json"

get "/" do
  @data = JSON.parse(open("nhl_data.json").read)
  erb :index
end
