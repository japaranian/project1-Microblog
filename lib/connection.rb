require 'active_record'

ActiveRecord::Base.establish_connection(
	:adapter => "postgresql",
	:host => "localhost",
	:username => "Japaranian",
	:database => "travel_blog"
	)