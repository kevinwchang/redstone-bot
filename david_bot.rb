require_relative 'redstone-bot.rb'

class DavidBot < Bot
  include JumpsOnCommand
end

DavidBot.new.run