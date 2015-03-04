require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'mustache'
require './lib/connection.rb'
require './lib/micropost.rb'
require './lib/user.rb'
require './lib/comment.rb'
require './lib/tag.rb'
require 'bcrypt'
require 'HTTParty'

after do
  ActiveRecord::Base.connection.close
end

configure do
	enable :sessions
	set :session_secret, 'secret'
end

get ('/') do
	erb :index
end

post ('/session') do
	user = User.find_by(email: params["email"])
	if user && user.autheticate(params["password"])
		session[:user_id] = user.id
		redirect '/explore'
	else
		@error = true
		render(:index)
	end
end

delete ('/session') do
	reset_session
	redirect_to "/"
end

get ('/users/new') do
	erb :new_user
end

post ('/users/create') do
	user = User.create(fname: params["fname"], lname: params["lname"], email: params["email"], password: params["password"] )
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
	# binding.pry
	micropost = Micropost.create(title: params["title"], post: params["entry"], user_id: params["user_id"], image_url: params["image"])
		if params["tags"].split.count == 0
			tag = Tag.create(tag_name: params["tags"], post_id: micropost["id"])
		else
			hashtags = params["tags"].split
			tags = hashtags.each do |tag|
			Tag.create(tag_name: tag, post_id: micropost["id"])
			end
		end

	redirect '/explore'
end

get ('/micropost/:id') do
	micropost = Micropost.find(params["id"])
	users = User.all.to_a
	comments = Comment.select{ |comments| comments["post_id"] == micropost["id"]}
	posts = Micropost.all.to_a
	tags = Tag.select{ |hashtags| hashtags["post_id"] == micropost["id"] }
	Mustache.render(File.read('./views/micropost/show.html'), {micropost: micropost, users: users, comments: comments, posts: posts, tags: tags, })
end

get ('/micropost/:id/edit') do
	micropost = Micropost.find(params["id"])
	users = User.all.to_a
	tags = Tag.select{ |hashtags| hashtags["post_id"] == micropost["id"]}
		tag_name = []
		tags.each do |hashtags|
			tag_name.push(hashtags.tag_name)
		end
		tag = tag_name.join(" ")
	Mustache.render(File.read('./views/micropost/edit.html'), {micropost: micropost, users: users, tag: tag})
end

put ('/micropost/:id/edit') do
	micropost = Micropost.find(params["id"])
	micropost.title = params["title"]
	micropost.post = params["entry"]
	micropost.image_url = params["image"]
	# binding.pry
	tags = Tag.where(post_id: micropost.id)
	tags.each do |tag|
		tag.destroy
	end

	new_tags = params["tag"].split
	new_tags.each do |tag|
		Tag.create(post_id: micropost["id"], tag_name: tag)
	end 

	micropost.save

	redirect "/micropost/#{params["id"]}"
end

delete ('/micropost/:id/edit') do
	# binding.pry
	micropost = Micropost.find(params["id"])
	comments = Comment.where post_id: params["id"]
	comments.each do |comment|
		comment.destroy
	end
	tags = Tag.where(post_id: micropost.id)
	tags.each do |tag|
		tag.destroy
	end
	
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

# get ('/tag/:tag_name') do
# 	tag = Tag.select{ |tags| tags["tag_name"] == params["tag_name"] }
# 	post_id = []
# 	tag.each do |hashtags|
# 		post_id.push(hashtags["post_id"])
# 	end

# 	Mustache.render(File.read('./views/micropost/show_tags.html'), {tag: tag, microposts: microposts})
# end