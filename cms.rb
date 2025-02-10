require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubi'

get '/' do
  @files = Dir.new('data').children.sort
  
  erb :index
end