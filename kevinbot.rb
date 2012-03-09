# coding: UTF-8

require 'matrix.rb'

require_relative 'redstone-bot.rb'

class KevinBot < Bot
	def initialize
		@targets = {}
		@jumping_start = Time.at(0)
		@y_velocity = 0.1
		@whitelist = [0x08]
	end

	def update_distance(target)
		target[:look_vector] = (target[:position] - @my_position)
		target[:distance] = target[:look_vector].magnitude
	end

	def update_all_distances
		@targets.each { |key, value| update_distance(value) }
	end

	def closest_target
		@targets.sort_by { |key, value| value[:distance] || Float::INFINITY }[0][1] if !@targets.empty?
	end

	def look_closest_target
		@closest = closest_target
		#if @closest != @last_closest || defined?(@last_closest) == nil
			if !@closest.nil?
				puts "#{Time.now}: Following #{@closest[:name]} (distance #{@closest[:distance]})"
			else
				puts "#{Time.now}: Following nobody"
			end
			@last_closest = @closest
		#end
		
		if !@closest.nil?
			x, y, z = @closest[:look_vector].to_a
			@position[:yaw] = Math::atan2(x, -z) * 180 / Math::PI + 180
			@position[:pitch] = -Math::atan2(y, Math::sqrt((x * x) + (z * z))) * 180 / Math::PI
		end
		#puts "y: #{@position[:yaw]}, p: #{@position[:pitch]}"
	end

	def react_to_target_position(target)
		if !@my_position.nil?
			update_distance(target)
			look_closest_target
		end
	end

	def handle_player_position_and_look(fields)
		last_position = @my_position
		super
		@my_position = Vector[@position[:x], @position[:y], @position[:z]]
		if @my_position != last_position
			update_all_distances 
			look_closest_target
		end	
	end

	def update_target_position_absolute(fields)
		@targets[fields[:eid]][:position] = Vector[fields[:x], fields[:y], fields[:z]] / 32.0
		react_to_target_position(@targets[fields[:eid]])
	end

	def update_target_position_relative(fields)
		@targets[fields[:eid]][:position] += Vector[fields[:dx], fields[:dy], fields[:dz]] / 32.0
		react_to_target_position(@targets[fields[:eid]])
	end

	def handle_named_entity_spawn(fields)
		@targets[fields[:eid]] = {name: fields[:player_name]}
		update_target_position_absolute(fields)
	end	

	def handle_entity_relative_move(fields)
		if @targets.has_key?(fields[:eid])
			update_target_position_relative(fields)
		end
	end

	def handle_entity_look_and_relative_move(fields)
		if @targets.has_key?(fields[:eid])
			update_target_position_relative(fields)
		end
	end

	def handle_entity_teleport(fields)
		if @targets.has_key?(fields[:eid])
			update_target_position_absolute(fields)
		end
	end

	def handle_destroy_entity(fields)
		@targets.delete(fields[:eid])
		look_closest_target
	end

	def handle_player_position_and_look(fields = {})
		@position = fields
		if @y_velocity > 0
			@jumphit = true
		else
			@landed = true
			@jumping_end = Time.now
			@y_velocity = 0
		end
		#puts "Received position: #{position_to_string}"
		send_player_position_and_look squelch: true
	end

#	LEASH = 5
#	SPEED_DIVIDER = 0.4
#	JUMP_VELOCITY = 7
#	GRAVITY = 1
#	JUMP_COOLDOWN = 2
	LEASH = 2
	SPEED_DIVIDER = 4
	JUMP_VELOCITY = 0.7
	GRAVITY = 0.1
	JUMP_COOLDOWN = 0.8

	def update_position
		if @closest != nil && @position != nil && @closest[:distance] > LEASH && @jumphit != true
			@position[:x] += @closest[:look_vector].normalize[0] / SPEED_DIVIDER
			@position[:z] += @closest[:look_vector].normalize[2] / SPEED_DIVIDER
		end

		if @y_velocity <= 0 && @landed == true && Time.now - @jumping_start > JUMP_COOLDOWN && @closest != nil && @closest[:distance] > LEASH
			@jumphit = false
			@jumping_start = Time.now
			@landed = false
			@y_velocity = JUMP_VELOCITY
		end

		@position[:on_ground] = 0
		@y_velocity -= GRAVITY
		change_y @y_velocity


		@my_position = Vector[@position[:x], @position[:y], @position[:z]]
		update_all_distances
		look_closest_target
 		send_player_position_and_look squelch: true
	end

end

KevinBot.new.run

