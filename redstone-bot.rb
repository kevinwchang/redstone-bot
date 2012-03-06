#!/usr/bin/ruby-rvm-env 1.9.3
# encoding: UTF-8

raise "Please use Ruby 1.9.3 or later." if RUBY_VERSION < "1.9.3"

require 'socket'
require 'io/wait'
require 'thread'

require_relative 'packets'
require_relative 'jumps_on_command'

if File.exist? 'config.rb'
	require_relative 'config.rb'
else
	require_relative 'default_config.rb'
end

class Bot
	attr_reader :health

	def run
		puts "Connecting to #{HOSTNAME}:#{PORT}..."
		@socket = TCPSocket.open HOSTNAME, PORT

		send_handshake USERNAME, HOSTNAME, PORT
		receive_packet

		send_login_request(username: USERNAME)
		eid = receive_packet[:eid]

		last_keep_alive = last_position_update = Time.at(0)
		
		while true
			if @socket.ready?
				receive_packet(whitelist: [])
			end

			now = Time.now
			if @position != nil && now - last_position_update >= 0.05
				update_position
				send_player_position_and_look squelch: true
				last_position_update = now
			end
			if now - last_keep_alive >= 1
				send_keep_alive(squelch: true)
				last_keep_alive = now
			end
		end
	end
	
	def parse_message(fields)
	end
	
	def parse_time(fields)
	end
	
	def respond_explosion(fields)
	end
	
	def handle_health(fields)
		@health = fields[:health]
		if @health <= 0
			Thread.new do
				sleep 1
				send_respawn
			end
		end
	end
	
	def dead?
		@health <= 0
	end
	
	def respond_entity_look(fields)
	end

	def handle_destroy_entity(fields)
	end
	
	def handle_entity_relative_move(fields)
	end
	
	def handle_entity_status(fields)
	end
	
	def handle_entity_look_and_relative_move(fields)
	end

	def handle_entity_teleport(fields)
	end

	def respond_chat(fields)
	end
	
	def handle_named_entity_spawn(fields)
	end

	def handle_respawn(fields)
	end
	
	def update_position
		fall
		@position[:on_ground] = 1
	end
	
	def fall(rate = 0.1)
		change_y -rate
	end
	
	def change_y(dy)
		@position[:y] += dy
		@position[:stance] += dy
	end
	
	def handle_player_position_and_look(fields = {})
		@position = fields
		puts "Received position: #{position_to_string}"
		send_player_position_and_look squelch: true
	end
	
	def position_to_string(position = @position)
		return "" if position.nil?
		"x,y,z = %3.2f,%3.2f,%3.2f g=%d p,y=%3.2f,%3.2f" % [
			position[:x], position[:y], position[:z],
			position[:on_ground], position[:pitch], position[:yaw]
		]
	end
	
	def parse_disconnect(fields = {})
		puts "Disconnected: #{fields[:reason].encode('US-ASCII')}"
		exit
	end
	
	def chat(message)
		send_chat_message message: message
	end
end


