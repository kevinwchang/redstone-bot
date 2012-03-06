module TimeOfDayReporter
	def parse_message(fields = {})
		if !['<', "\u00A7"].include?(fields[:message][0].encode('UTF-8')) && fields[:message].split[0].encode('UTF-8') != USERNAME
			send_chat_message(message: 'HA HA')
		end
	end

	def time_of_day(time)
		case time
			when 0..5999 then :day_am
			when 6000..11999 then :day_pm
			when 12000..13799 then :sunset
			when 13800..17999 then :night_pm
			when 18000..22199 then :night_am
			when 22200..23999 then :sunrise
			end
	end

	def parse_time(fields = {})
		time = fields[:time] % 24000
		tod = time_of_day(time)

		if @last_time == nil
			@last_time = tod
			puts "Time is #{time}; initializing @last_time to #{tod.to_s}"
		elsif @last_time != tod
			@last_time = tod
			send_chat_message(message: case tod
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
end