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
	hashtags = params["tags"].split
		hashtags.each do |tag|
		tags = Tag.create(tag_name: tag, post_id: micropost["id"])
		end

	redirect '/explore'
end

get ('/micropost/:id') do
	# binding.pry
	micropost = Micropost.find(params["id"])
	users = User.all.to_a
	comments = Comment.find_by post_id: params["id"]
		if comments == true then user_name = User.find_by id: comments["user_id"]
		end
	posts = Micropost.all.to_a
	tags = Tag.select{ |hashtags| hashtags["post_id"] == micropost["id"] }
		tags_cleaned = tags.each do |hashtags|
			hashtags["tag_name"].gsub(/#/, "")
		end
	Mustache.render(File.read('./views/micropost/show.html'), {micropost: micropost, users: users, comments: comments, posts: posts, tags: tags, user_name: user_name, tags_cleaned: tags_cleaned})
end

get ('/micropost/:id/edit') do
	micropost = Micropost.find(params["id"])
	users = User.all.to_a
	tag = Tag.select{ |hashtags| hashtags["post_id"] == micropost["id"]}
	Mustache.render(File.read('./views/micropost/edit.html'), {micropost: micropost, users: users, tag: tag})
end

put ('/micropost/:id/edit') do
	binding.pry
	micropost = Micropost.find(params["id"])
	micropost.title = params["title"]
	micropost.post = params["entry"]
	micropost.image_url = params["image"]
	
	tag = Tag.find_by post_id: params["id"]
	hashtags = params["tags"].split
		hashtags.each do |tag|
	tag.tag_name = tag

	micropost.save
	tag.save

	redirect "/micropost/#{params["id"]}"
end

delete ('/micropost/:id/edit') do
	micropost = Micropost.find(params["id"])
	comment = Comment.find_by post_id: params["id"]
	tag = Tag.find_by post_id: params["id"]

	comment.destroy
	tag.destroy
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

get ('/tag/:tags_cleaned') do
	tag = Tag.find(params["tag_name"])
	microposts = Micropost.find_by id: tag["post_id"]

	Mustache.render(File.read('./views/micropost/show_tags.html'), {tag: tag, microposts: microposts})
end