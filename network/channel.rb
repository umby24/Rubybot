class Channel
	attr_accessor :topic
	attr_reader :users, :name

	def initialize(channel)
		@name = channel
		@users = []
	end

	def set_users(users_string)

	end
end