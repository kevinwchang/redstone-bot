require_relative 'redstone-bot.rb'

module JumpsOnCommand
  def update_position
	  @position[:y] -= 0.1
		@position[:stance] -= 0.1
		@position[:on_ground] = 1
	end
end

class DavidBot < Bot
end

DavidBot.new.run