require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubi'

root = File.expand_path("..", __FILE__)

before do
	@files = Dir.glob(root + '/data/*')
end

get '/' do
	@files = @files.map { |path| File.basename(path) }	

  erb :index
end

get '/:file_name' do
	file_name = params[:file_name]
	file_path = root + '/data/' + file_name

	@file = File.readlines(file_path)

	headers['Content-Type'] = 'text/plain'
	erb :file
end