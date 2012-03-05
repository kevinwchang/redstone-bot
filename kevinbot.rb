# coding: UTF-8

require 'matrix.rb'

require_relative 'redstone-bot.rb'

class KevinBot < Bot
	def initialize
		@targets = {}
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
		@landed = true
    #puts "Received position: #{position_to_string}"
    send_player_position_and_look squelch: true
  end

	FallRate = 0.5
  JumpRate = 0.5
  JumpTime = 0.2
	def update_position
		if @closest != nil && @position != nil && @closest[:distance] > 2
			@position[:x] += @closest[:look_vector].normalize[0] / 4
			@position[:z] += @closest[:look_vector].normalize[2] / 4
			puts @closest[:look_vector][1]
			if @jumping != true && @landed == true
				@jumping = true
        @jumping_start = Time.now
				@landed = false
			end
		end

		if @jumping
						@position[:on_ground] = 0
						change_y JumpRate
						if Time.now - @jumping_start > JumpTime
										@jumping = false
						end
		else
						fall FallRate
		end


		@my_position = Vector[@position[:x], @position[:y], @position[:z]]
		update_all_distances
		look_closest_target
 		send_player_position_and_look squelch: true
	end

end

KevinBot.new.run

