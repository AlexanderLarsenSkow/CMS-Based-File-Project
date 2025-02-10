require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubi'

get '/' do
  'Getting started.'
end