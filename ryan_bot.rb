# coding: UTF-8

require_relative 'redstone-bot.rb'

HIT_RESPONSES = <<END.split("\n")
Dispersing.
We are in peril!
I...cannot maintain!
We are in peril!
We cannot hold!
The enemy closes.
Defensive systems failing.
Breach in progress! We are undone!
They've broken through.
Fall back to the shadows!
Prismatic core failing!
We cannot hold!
It's getting too hot!
Uhh... I'm in a heap of trouble!
I'm in a world of hurt!
Somebody get me out of this mess!
We're screwed.
I'm too young to die!
Help!
Not what I had in mind!
I'm in deep!
Can't hold them alone!
Mmmm...My goose is getting cooked!
Umm. Better send some body bags!
I'm in a pickle!
Where's my backup?
Whoa, they're all over me!
END

module TimeOfDayReporter
	def parse_message(fields = {})
		if !['<', "\u00A7"].include?(fields[:message][0].encode('UTF-8')) && fields[:message].split[0].encode('UTF-8') != USERNAME
			send_chat_message(message: 'HA HA')
		end
	end

	def time_of_day(time)
		case time
			when 0..5999 then :day_am
			when 6000..11999 then :day_pm
			when 12000..13799 then :sunset
			when 13800..17999 then :night_pm
			when 18000..22199 then :night_am
			when 22200..23999 then :sunrise
			end
	end

	def parse_time(fields = {})
		time = fields[:time] % 24000
		tod = time_of_day(time)

		if @last_time == nil
			@last_time = tod
			puts "Time is #{time}; initializing @last_time to #{tod.to_s}"
		elsif @last_time != tod
			@last_time = tod
			send_chat_message(message: case tod
				when :day_am then 'It is day!'
				when :day_pm then 'It is noon!'
				when :sunset then 'The sun is setting!'
				when :night_pm then 'It is night!'
				when :night_am then 'It is midnight!'
				when :sunrise then 'The sun is rising!'
				end
			)
		end
	end
end

module JumpsOnCommand
	def respond_chat(fields)
		if fields[:message] =~ /<([^>]+)> jump!/
			chat "OK, #{$1}!"
		end
		if fields[:message] =~ /<([^>]+)> where are you?/
			chat "I am at, x:#{@position_fields[:x]} z:#{@position_fields[:z]} y:#{@position_fields[:y]}!"
		end
	end
end

class RyanBot < Bot
	include TimeOfDayReporter
	include JumpsOnCommand
	
	def handle_respawn(fields)
		chat "Hello, sirs or madams."
	end
	
	def handle_entity_status(fields)
		if fields[:status] == 2
			@followee_eid = fields[:eid]
		end
	end
	
	def handle_explosion(fields = {})
		chat 'YOUR HEAD A SPLODE'
	end
	
	def handle_entity_look(fields)
		#fields[:yaw] = read_byte
		#	fields[:pitch] = read_byte
		@position_fields[:pitch] = fields[:yaw]
		@position_fields[:yaw] = fields[:pitch]
	end
	
	def handle_entity_look_and_relative_move(fields)
		if fields[:eid] == @followee_eid
			@position_fields[:stance] += fields[:dy]/2
			@position_fields[:y] += fields[:dy]/2
			@position_fields[:x] += fields[:dx]/2
			@position_fields[:z] += fields[:dz]/2
			respond_entity_look(fields)
		end
	end
end

RyanBot.new.run