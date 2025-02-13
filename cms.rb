require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubi'
require 'redcarpet'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

helpers do
  def flash_message(name)
    if session[name]
      "<p class = 'flash'>#{session.delete(name)}</p>"
    end
  end
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
    erb render_markdown(content)
  end
end

before do
  @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  pattern = File.join(data_path, '*')
	@files = Dir.glob(pattern)
end

get '/' do
	@files = @files.map { |path| File.basename(path) }
  erb :home
end

get '/new' do
  erb :new
end

def invalid_file?(file_name)
  file_name.size == 0 || File.extname(file_name) == ''
end

def determine_create_error(file_name)
  if file_name.size == 0
    session[:error] = 'A name is required.'
  
  else
    session[:error] = 'Include an extname (.txt, .md, etc.)'
  end
end

post '/create' do
  file_name = params[:document].strip

  if invalid_file?(file_name)
    determine_create_error(file_name)
    status 422
    erb :new

  else
    @new_file = File.new("#{data_path}/#{file_name}", 'w+')
    session[:success] = "#{file_name} was created."
    
    redirect '/'
  end
end

def set_up_file
  @file_name = params[:file_name]
  @file_path = File.join(data_path, @file_name)
end

get '/:file_name' do
  set_up_file

  if @files.include? @file_path
    load_content(@file_path)

  else
    session[:error] = "Sorry, that file doesn't exist."
    redirect '/'
  end
end

get '/:file_name/edit' do
  set_up_file
  @content = File.read(@file_path)
  erb :edit
end

post '/:file_name' do
  set_up_file
  edits = params[:edit]
  File.write(@file_path, edits)

  session[:success] = "#{@file_name} has successfully been edited."
  redirect '/'
end
