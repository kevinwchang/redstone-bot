#!/usr/bin/ruby-rvm-env 1.9.3

require 'socket'
require 'io/wait'
require 'thread'

require_relative 'packets'

def parse_time(fields = {})
	#puts fields[:time] % 24000
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
Prismatic core failing; we require assistance!
We cannot hold!
Lend me your support.
Lend me your aid!
Mayday! Mayday!
It's a trap!
Abandon ship!
It's getting too hot!
Uhh... I'm in a heap of trouble!
I'm in a world of hurt!
We could use some help here!
Somebody get me out of this mess!
This vessel requires assistance!
We're screwed.
I'm too young to die!
Help!
Not what I had in mind!
I'm in deep!
Can't hold them alone!
Get me outta here!
Mmmm...My goose is getting cooked!
If I die, I'll kill ya!
Umm. Better send some body bags!
I'm in a pickle!
Where's my backup?
How about lending a hand?
Whoa, they're all over me!
END

def respond_health(fields = {})
	if (@health != nil && fields[:health] < @health)
		if (fields[:health] <= 0)
			Thread.new do
				sleep(3)
				send_respawn()
				send_chat_message(message: "I have returned!")
			end
		elsif (@health != nil && fields[:health] < @health)
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
	update_position()
end

def parse_disconnect(fields = {})
	puts "Disconnected: #{fields[:reason].encode('US-ASCII')}"
	exit
end

USERNAME = 'timekeeper'
PROTOCOL_VERSION = 23

@socket = TCPSocket.open('localhost', 25565)

send_handshake(username: USERNAME)
receive_packet()

send_login_request(username: USERNAME, protocol_version: PROTOCOL_VERSION)
receive_packet()

last_keep_alive = last_position_update = Time.at(0)

while (true)
	if (@socket.ready?)
		receive_packet(handler_0x04: method(:parse_time),
									 handler_0x08: method(:respond_health),
									 handler_0x0D: method(:respond_position),
									 handler_0xFF: method(:parse_disconnect),
		               whitelist: [0x08, 0x0D],
									 blacklist: [0x00, 0x04, 0x05, 0x12, 0x15, 0x18, 0x19, 0x1C, 0x1D, 0x1F, 0x20, 0x21, 0x22, 0x28, 0x32, 0x33, 0x34, 0x35, 0x36, 0x82, 0xC8, 0xC9])
	end

	now = Time.now
	if (@position_fields != nil && now - last_position_update >= 0.05)
		update_position(squelch: true)
		last_position_update = now
	end
	if (now - last_keep_alive >= 1)
		send_keep_alive(squelch: true)
		last_keep_alive = now
	end
end
