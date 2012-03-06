require_relative 'redstone-bot.rb'

class DavidBot < Bot
  include JumpsOnCommand
	
	def respond_respawn
		chat "DavidBot is here!"
	end
end

DavidBot.new.run