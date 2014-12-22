require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'mustache'
require './lib/connection.rb'
require './lib/micropost.rb'
require './lib/user.rb'
require './lib/comment.rb'
require './lib/tag.rb'
require './lib/tag_ref.rb'

get '/' do
	File.read('./views/index.html')
end

post '/user' do
	user = User.create(name: params["name"], email: params["email"] )
	redirect '/explore'
end

get '/explore' do
	# binding.pry
	microposts = Micropost.all.to_a
	Mustache.render(File.read('./views/micropost/explore.html'), {microposts: microposts})
end

get '/micropost/new' do
	users = User.all.to_a
	Mustache.render(File.read('./views/new_blog.html'), {users: users})
end

post '/micropost' do
	micropost = Micropost.create(title: params["title"], post: params["entry"], user_id: params["user_id"], image_url: params["image"], tag: params["tags"])
	redirect '/explore'
end