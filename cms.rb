require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubi'
require 'redcarpet'

root = File.expand_path("..", __FILE__)

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

def render_markdown(text)
  @markdown.render(text)
end

def load_content(path)
  content = File.read(path)
  
  case File.extname(path)
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    content
  
  when '.md'
    render_markdown(content)
  end
end

before do
  @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
	@files = Dir.glob(root + '/data/*')
end

get '/' do
	@files = @files.map { |path| File.basename(path) }
  erb :home
end

get '/favicon.ico' do
  redirect '/'
end

get '/:file_name' do
	file_name = params[:file_name]
	file_path = root + '/data/' + file_name

  if @files.include? file_path
    load_content(file_path)

  else
    session[:error] = "Sorry, that file doesn't exist."
    redirect '/'
  end
end
