class ChatMessage
	attr_accessor :message

	def initialize(message)
		@message = message
	end
	
	def self.from_message(message)
		case message
			when /^<([^>]+)> (.*)/ then UserChatMessage.new(message, $1, $2)
			when /^\u00A7([0-9a-f])(.*)/ then ColoredMessage.new(message, $1.to_i(16), $2)
			else DeathMessage.new(message)
			end
	end
	
	def to_s
		"unrecognized type of chat: #{message.inspect}"
	end
end

class UserChatMessage < ChatMessage
	attr_accessor :username, :contents
	
	def initialize(message, username, contents)
		@message = message
		@username = username
		@contents = contents
	end
	
	def to_s
		"chat: <#{username}> #{contents}"
	end
end

class ColoredMessage < ChatMessage
	attr_accessor :color_code, :contents
	
	def initialize(message, color_code, contents)
		@message = message
		@color_code = color_code
		@contents = contents
	end
	
	def to_s
		"chat: #{contents}"
	end
	
end

class DeathMessage < ChatMessage
	attr_accessor :contents, :username, :death_type, :killer_name
	
	def initialize(message)
		@message = @contents = message

		@death_type = case message
			when /^(.+) drowned$/ then :drowned
			when /^(.+) hit the ground too hard$/ then :hit_ground
			when /^(.+) was slain by (.+)$/ then :slain
			when /^(.+) was shot by (.+)$/ then :shot
			when /^(.+) was killed by (.+)$/ then :killed
			when /^(.+) fell out of the world (.+)$/ then :fell_out
			when /^(.+) tried to swim in lava$/ then :lava
			when /^(.+) went up in flames$/ then :flames
			when /^(.+) burned to death$/ then :burned
			when /^(.+) blew up$/ then :blew_up
			when /^(.+) was fireballed by (.+)$/ then :fireballed
			when /^(.+) was killed by magic$/ then :magic   # suicide
			when /^(.+) suffocated in a wall$/ then :suffocated
			when /^(.+) was pricked to death$/ then :pricked
			when /^(.+) was shot by an arrow$/ then :arrow
			when /^(.+) died$/ then :died
			when /^(.+) didn't have a chance$/ then :no_chance
			when /^([^\s]*)$/ then :unknown
			end
		
		@username = $1
		@killer_name = $2   # mob or player name
	end
	
	def to_s
		"death: #{message}"
	end
end