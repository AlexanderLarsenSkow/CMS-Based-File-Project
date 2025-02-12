ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../cms'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_home
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']

    assert_includes last_response.body, "/about.md"
    assert_includes last_response.body, "/changes.txt"
    assert_includes last_response.body, "/history.txt"
  end

  def test_about
    get '/about.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
  
    header = 'Ruby is...'
    body = 'primarily a backend programming language'
     
    assert_includes last_response.body, body
    assert_includes last_response.body, header
  end

  def test_changes
    get '/changes.txt'

    assert_equal 'text/plain', last_response['Content-Type']
    message = 'Ruby has had so many changes over the years'

    assert_includes last_response.body, message
  end

  def test_history_file
    get '/history.txt'
    message = '1996 - Ruby 1.0 released.'
    
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
end