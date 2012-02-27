#!/usr/bin/ruby-rvm-env 1.9.3
# encoding: UTF-8

require 'socket'
require 'io/wait'
require 'thread'

require_relative 'packets'

USERNAME = 'ಠ_ಠ'

def parse_message(fields = {})
	if !['<', "\u00A7"].include?(fields[:message][0].encode('UTF-8')) && fields[:message].split[0].encode('UTF-8') != USERNAME
		send_chat_message(message: 'HA HA')
	end
end

def time_of_day(time)
	return case time
	when 0..5999 then :day_am
	when 6000..11999 then :day_pm
	when 12000..13799 then :sunset
	when 13800..17999 then :night_pm
	when 18000..22199 then :night_am
	when 22200..23999 then :sunrise
	end
end

@last_time = nil

def parse_time(fields = {})
	time = fields[:time] % 24000
	tod = time_of_day(time)

	if @last_time == nil
		@last_time = tod
		puts "Time is #{time}; initializing @last_time to #{tod.to_s}"
	elsif @last_time != tod
		@last_time = tod
		send_chat_message(message:
			case tod
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

@health = nil

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

def respond_health(fields = {})
	if @health != nil && fields[:health] < @health
		if fields[:health] <= 0
			Thread.new do
				sleep(4)
				send_respawn
				send_chat_message(message: "I have returned!")
			end
		elsif @health != nil && fields[:health] < @health
			send_chat_message(message: HIT_RESPONSES[rand(0..(HIT_RESPONSES.size - 1))]) if (rand(0..1) == 1)
		end
	end

	@health = fields[:health]
end

@position_fields = nil

def update_position(opts = {})
	send_player_position_and_look(opts.merge(@position_fields))
end

def respond_position(fields = {})
  @position_fields = fields
	@position_fields[:on_ground] = 1
	@position_fields[:yaw] = 270
	update_position
end

def parse_disconnect(fields = {})
	puts "Disconnected: #{fields[:reason].encode('US-ASCII')}"
	exit
end

PROTOCOL_VERSION = 23

@socket = TCPSocket.open('localhost', 25565)

send_handshake(username: USERNAME)
receive_packet

send_login_request(username: USERNAME, protocol_version: PROTOCOL_VERSION)
receive_packet

last_keep_alive = last_position_update = Time.at(0)

while true
	if @socket.ready?
		receive_packet(
			handler_0x03: method(:parse_message),
			handler_0x04: method(:parse_time),
			handler_0x08: method(:respond_health),
			handler_0x0D: method(:respond_position),
			handler_0xFF: method(:parse_disconnect),
		  whitelist: [0x03, 0x08, 0x0D]
		)
	end

	now = Time.now
	if @position_fields != nil && now - last_position_update >= 0.05
		update_position(squelch: true)
		last_position_update = now
	end
	if now - last_keep_alive >= 1
		send_keep_alive(squelch: true)
		last_keep_alive = now
	end
end

