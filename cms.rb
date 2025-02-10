require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubi'

root = File.expand_path("..", __FILE__)

get '/' do
  @files = Dir.glob(root + '/data/*').map { |path| File.basename(path) }

  erb :index
end