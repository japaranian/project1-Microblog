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

get ('/') do
	File.read('./views/index.html')
end

post ('/user') do
	user = User.create(name: params["name"], email: params["email"] )
	redirect '/explore'
end

get ('/user/:id') do
	user = User.find(params["id"])
	micropost = Micropost.select{ |post| post["user_id"] == user["id"] }
	Mustache.render(File.read('./views/user/show.html'), {user: user, micropost: micropost})
end

get ('/explore') do
	microposts = Micropost.all.to_a
	Mustache.render(File.read('./views/micropost/explore.html'), {microposts: microposts})
end

get ('/micropost/new') do
	users = User.all.to_a
	Mustache.render(File.read('./views/new_blog.html'), {users: users})
end

post ('/micropost') do
	micropost = Micropost.create(title: params["title"], post: params["entry"], user_id: params["user_id"], image_url: params["image"])
	tags = Tag.create(tag_name: params["tags"])

	redirect '/explore'
end

get ('/micropost/:id') do
	micropost = Micropost.find(params["id"])
	users = User.all.to_a
	comments = Comment.select{ |comments| comments["post_id"] == micropost["id"]}
	posts = Micropost.all.to_a
	tags = Tag.all.to_a
	Mustache.render(File.read('./views/micropost/show.html'), {micropost: micropost, users: users, comments: comments, posts: posts, tags: tags})
end

get ('/micropost/:id/edit') do
	micropost = Micropost.find(params["id"])
	users = User.all.to_a
	Mustache.render(File.read('./views/micropost/edit.html'), {micropost: micropost, users: users})
end

put ('/micropost/:id/edit') do
	micropost = Micropost.find(params["id"])
	micropost.title = params["title"]
	micropost.post = params["entry"]
	micropost.image_url = params["image"]

	micropost.save

	redirect "/micropost/#{params["id"]}"
end

delete ('/micropost/:id/edit') do
	micropost = Micropost.find(params["id"])
	micropost.destroy

	redirect '/explore'
end

post ('/comment') do
 	comment = Comment.create(user_id: params["user_id"], content: params["comment"], post_id: params["post_id"])

	redirect "/micropost/#{params["post_id"]}"
end

get ('/comment/:id') do
	comments = Comment.find(params["id"])
	users = User.all.to_a
	posts = Micropost.all.to_a
	Mustache.render(File.read('./views/comment/comment_edit.html'), {comments: comments, users: users, posts: posts})
end

put ('/comment/:id') do 
	comment = Comment.find(params["id"])
	comment.content = params["comment"]
	comment.user_id = params["user_id"]
	comment.post_id = params["post_id"]
	comment.save

	redirect "/micropost/#{params["post_id"]}"
end