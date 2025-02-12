require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubi'
require 'redcarpet'

root = File.expand_path("..", __FILE__)

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

before do
  @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
	@files = Dir.glob(root + '/data/*')
end

get '/' do
	@files = @files.map { |path| File.basename(path) }
  erb :index
end

get '/favicon.ico' do
  redirect '/'
end

get '/:file_name' do
	file_name = params[:file_name]
	file_path = root + '/data/' + file_name

  if !@files.include? file_path
    session[:error] = "Sorry, that file doesn't exist."
    redirect '/'
  end

  @file = File.readlines(file_path)

	headers['Content-Type'] = 'text/plain'
	erb :file
end
