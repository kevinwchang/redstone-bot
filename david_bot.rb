require_relative 'redstone-bot.rb'

class DavidBot < Bot
  include JumpsOnCommand
	
	def handle_respawn(fields)
		super
		chat "#{username} is here!"
	end
end

DavidBot.new.run