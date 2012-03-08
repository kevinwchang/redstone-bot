require_relative 'redstone-bot.rb'

module EvaluatesRuby
	def handle_chat(message)
		if message.is_a?(UserChatMessage) && message.contents =~ /eval (.+)/
			string = $1
			result = nil
			thread = Thread.new do
				$SAFE = 4
				result = begin
					eval string
				rescue Exception => e
					e.message
				end
			end
			if !thread.join(0.5)
				thread.kill
				result = ":("
			end
			
			case result
				when String then chat result
				when nil then
				else chat result.inspect
				end
		end
	end
end

module GreetsElavid
	def handle_chat(message)
		if message.is_a?(ColoredMessage) && message.contents == "Elavid joined the game."
			later(3) do
			  chat 'WOOHOO Elavid is here!'
			end
		end
	end
end

class DavidBot < Bot
  include JumpsOnCommand
	include GreetsElavid
	include EvaluatesRuby
	
	def handle_respawn(fields)
		chat "#{username} is here!"
	end
	
	def handle_chat(message)
		return unless message.is_a?(DeathMessage)
		return if message.username == username
		response = case message.death_type
			when :drowned then "Swimming is fun, right #{message.username}?"
			when :hit_ground then "That sounds painful."
			when :slain, :shot, :killed then "Way to go, #{message.killer_name}!"
			when :fell_out then nil
			when :lava, :flames, :burned then "#{message.username} in oven.  No turn on."
			when :blew_up then "KABOOM!!!!"
			when :fireballed then nil
			when :magic then nil
			when :suffocated then "Watch out for dangerous walls, #{message.username}!"
			when :pricked then "WOW, FOR REAL #{message.username.upcase}??"
			when :arrow then "Happy Valentines Day, #{message.username}."
			when :died then "R.I.P. #{message.username}"
			when :no_chance then "I thought #{message.username} had a chance."
			end
			
		chat response if response
	end
end

DavidBot.new.run