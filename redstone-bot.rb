#!/usr/bin/ruby-rvm-env 1.9.3
# encoding: UTF-8

raise "Please use Ruby 1.9.3 or later." if RUBY_VERSION < "1.9.3"

require 'socket'
require 'io/wait'
require 'thread'

require_relative 'packets'

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
				receive_packet(
					handler_0x03: method(:parse_message),
					handler_0x04: method(:parse_time),
					handler_0x08: method(:respond_health),
					handler_0x0D: method(:respond_position),
					handler_0x3C: method(:respond_explosion),
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
	end
	
	def parse_message(fields)
	end
	
	def parse_time(fields)
	end
	
	def update_position(opts = {})
		send_player_position_and_look(opts.merge(@position_fields))
	end

	def respond_position(fields = {})
		@position_fields = fields
		@position_fields[:on_ground] = 1
		@position_fields[:pitch] = 0
		@position_fields[:yaw] = 270
		update_position
	end
	
	def parse_disconnect(fields = {})
		puts "Disconnected: #{fields[:reason].encode('US-ASCII')}"
		exit
  end
end


