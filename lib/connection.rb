require 'active_record'

ActiveRecord::Base.establish_connection('postgresql://' + ENV["DB_INFO"] + '@127.0.0.1/travel_blog')

  ActiveRecord::Base.logger = Logger.new(STDOUT)