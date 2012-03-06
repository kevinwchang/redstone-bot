# coding: UTF-8
require_relative 'redstone-bot'
require_relative 'floater'

class RyanBot < Bot
	include Floater
	
	def handle_respawn(fields)
		chat "Hello, sirs and/or madams."
	end
	
	def handle_entity_status(fields)
		if fields[:status] == 2
			@followee_eid = fields[:eid]
		end
	end
end

RyanBot.new.run