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
	
	def respond_chat(fields)
		if fields[:message] =~ /<([^>]+)> jump!/
			chat "OK, #$1!"
			@jumping = true
			@jumping_start = Time.now
		end
	end
end