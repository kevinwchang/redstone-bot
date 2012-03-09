require 'matrix'

module Floater

	def update_height(y)
		@position[:y] = y
		@position[:stance] = y+1
	end
	
	def update_position
		above_player = 3
		@ground_height ||= 65
		@update_times ||= 0
		@update_times +=1
		if @position[:y] <= @ground_height+above_player
			if @update_times % 45 == 0
				update_height(@ground_height)
				send_player_position_and_look squelch: true
			end
			update_height(@ground_height+above_player)
		else
			fall(0.05)
			#@position[:on_ground] = 1
		end
	end
	
	def react_to_target_position(target)
		if !@my_position.nil? && target[:name] == "kevinbot"
			@position[:x] = target[:position][0]
			@ground_height = target[:position][1]
			@position[:z] = target[:position][2]
		end
	end
	
	def handle_player_position_and_look(fields)
		super
		@my_position = Vector[@position[:x], @position[:y], @position[:z]]
	end
	
	def handle_named_entity_spawn(fields)
		@targets ||= {}
		@targets[fields[:eid]] = {name: fields[:player_name]}
		update_target_position_absolute(fields)
	end	
	
	def update_target_position_absolute(fields)
		@targets ||= {}
		@targets[fields[:eid]][:position] = Vector[fields[:x], fields[:y], fields[:z]] / 32.0
		react_to_target_position(@targets[fields[:eid]])
	end

	def update_target_position_relative(fields)
		@targets ||= {}
		@targets[fields[:eid]][:position] += Vector[fields[:dx], fields[:dy], fields[:dz]] / 32.0
		react_to_target_position(@targets[fields[:eid]])
	end
	
	def handle_entity_relative_move(fields)
		@targets ||= {}
		if @targets.has_key?(fields[:eid])
			update_target_position_relative(fields)
		end
	end
	
	def handle_entity_look_and_relative_move(fields)
		@targets ||= {}
		if @targets.has_key?(fields[:eid])
			update_target_position_relative(fields)
		end
	end

	def handle_entity_teleport(fields)
		@targets ||= {}
		if @targets.has_key?(fields[:eid])
			update_target_position_absolute(fields)
		end
	end
	
	def handle_destroy_entity(fields)
		@targets ||= {}
		@targets.delete(fields[:eid])
	end
	
end