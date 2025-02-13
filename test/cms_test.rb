ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'fileutils'

require_relative '../cms'

def create_document(name, content = '')
	File.open(File.join(data_path, name), 'w') do |file|
		file.write(content)
	end
end

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

	def setup
		FileUtils.mkdir_p(data_path)
	end

	def teardown
		FileUtils.rm_rf(data_path)
	end

  def test_home
		create_document 'about.md'
		create_document 'changes.txt'
		create_document 'history.txt'

    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']

    assert_includes last_response.body, "/about.md"
    assert_includes last_response.body, "/changes.txt"
    assert_includes last_response.body, "/history.txt"
  end

  def test_about
		create_document('about.md', 'Ruby is...')

    get '/about.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
  
    header = 'Ruby is...'
     
    assert_includes last_response.body, header
  end

  def test_changes
		message = 'Ruby has had so many changes'
		create_document('changes.txt', message)

    get '/changes.txt'

    assert_equal 'text/plain', last_response['Content-Type']
    assert_includes last_response.body, message
  end

  def test_history_file
		message = '1996 - Ruby 1.0 released.'
		create_document('history.txt', message)

    get '/history.txt'
    
    assert_includes last_response.body, message
  end

  def test_bad_route
    get '/about.tx'
    error = "Sorry, that file doesn't exist."
    assert_equal 302, last_response.status

    follow_redirect!
    assert_equal 200, last_response.status
    assert_includes last_response.body, error
  end

  def test_editing_document
    initial_content = "Ruby has had so many changes over the years"
		create_document('changes.txt', initial_content)

    get "/changes.txt/edit"

    assert_equal 200, last_response.status
    assert_includes last_response.body, initial_content
    assert_includes last_response.body, '<textarea'
    assert_includes last_response.body, %q(<button type = "submit")
  end
  
  def test_updating_document
		create_document('changes.txt', 'Ruby')
		initial_content = 'has had so many changes'

    post "/changes.txt", edit: initial_content
    assert_equal 302, last_response.status

    get last_response["Location"]

    assert_includes last_response.body, "changes.txt has successfully been edited"

    get "/changes.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "so many changes"
  end

  def test_new_doc_route
    get '/new'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<input'
    assert_includes last_response.body, %q(button type = "submit")
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
  end

  def test_new_document
    post '/create', document: 'new.txt'
    assert_equal 302, last_response.status

    follow_redirect!

    assert_equal 200, last_response.status
    assert_includes last_response.body, 'new.txt was created.'
    assert_includes last_response.body, 'new.txt'

    get '/new.txt'
    assert_equal 200, last_response.status
  end

  def test_create_error
    post '/create', document: ''

    assert_equal 422, last_response.status
    assert_includes last_response.body, 'A name is required.'

    post '/create', document: 'asdf'

    assert_equal 422, last_response.status
    assert_includes last_response.body, 'Include an extname'
  end

  def test_delete
    create_document 'test.txt'
    
    post "/test.txt/delete"

    assert_equal 302, last_response.status

    follow_redirect!
    assert_includes last_response.body, "test.txt has been deleted."

    get '/'
    refute_includes last_response.body, "test.txt"
  end
end
