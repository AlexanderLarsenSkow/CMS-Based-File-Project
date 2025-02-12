require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubi'
require 'redcarpet'

ROOT = File.expand_path("..", __FILE__)

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

helpers do
  def flash_message(name)
    if session[name]
      "<p>#{session.delete(name)}</p>"
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
    render_markdown(content)
  end
end

def load_edits(content)
  case File.extname(@file_name)
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    content

  when '.md'
    render_markdown(content)
  end
end

before do
  @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
	@files = Dir.glob(ROOT + '/data/*')
end

get '/' do
	@files = @files.map { |path| File.basename(path) }
  erb :home
end

get '/favicon.ico' do
  redirect '/'
end

def set_up_file
  @file_name = params[:file_name]
  @file_path = ROOT + '/data/' + @file_name
end

get '/:file_name' do
  set_up_file
  
  if session[@file_name]
    content = session[@file_name]
    load_edits(content)

  elsif @files.include? @file_path
    load_content(@file_path)

  else
    session[:error] = "Sorry, that file doesn't exist."
    redirect '/'
  end
end

get '/:file_name/edit' do
  set_up_file
  @content = session[@file_name] || File.read(@file_path)
  erb :edit
end

post '/:file_name' do
  set_up_file
  edits = params[:edit]

  session[@file_name] = edits
  session[:success] = "#{@file_name} has successfully been edited."
  redirect '/'
end
