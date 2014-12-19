require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'mustache'
require './lib/connection.rb'
require './lib/micropost.rb'
require './lib/author.rb'
require './lib/comment.rb'
require './lib/tag.rb'
require './lib/tag_ref.rb'

get '/' do
	File.read('./views/index.html')
end

get '/blog/new' do
	File.read('./views/new_blog.html')
end

post '/blog' do
	
end