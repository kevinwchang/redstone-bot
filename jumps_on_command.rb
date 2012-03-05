module JumpsOnCommand
  def update_position
		if @jumping
			@position[:on_ground] = 0
			change_y 0.1
			if Time.now - @jumping_start > 2
				@jumping = false
			end
		else
			fall
		end
	end
	
	def respond_chat(fields)
		if fields[:message] =~ /<[^>]+> jump!/
			chat "OK!"
			@jumping = true
			@jumping_start = Time.now
		end
	end
end