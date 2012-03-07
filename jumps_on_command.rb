module JumpsOnCommand
	FallRate = 0.1
	JumpRate = 0.2
	JumpTime = 1

	def update_position
		if @jumping
			@position[:on_ground] = 0
			change_y JumpRate
			if Time.now - @jumping_start > JumpTime
				@jumping = false
			end
		else
			fall FallRate
		end
	end
	
	def handle_chat(message)
		super
		if message.is_a?(UserChatMessage) && message.contents == 'jump!'
			chat "OK, #{message.username}!"
			@jumping = true
			@jumping_start = Time.now
		end
	end
end