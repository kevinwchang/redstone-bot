require_relative 'redstone-bot.rb'

class DavidBot < Bot
  include JumpsOnCommand
	
	def handle_respawn
		super
		chat "DavidBot is here!"
	end
end

DavidBot.new.run