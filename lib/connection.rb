require 'active_record'

ActiveRecord::Base.establish_connection(
	:adapter => "postgresql",
	:host => "locahost",
	:username => "Japaranian",
	:database => "travel_blog"
	)