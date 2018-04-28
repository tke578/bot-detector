require 'pry'
require 'json'

def bot_detector(input_file_path)
	# this will hold collection of all unique users
	row_object = {}

	File.open(input_file_path).each_line do |line|
		if line.size >  1
			current = JSON.parse(line)
			if row_object[current["user"]].nil?
				row_object[current["user"]] = []
			end

			row_object[current["user"]] << current
		end
	end

	possible_bot_users = row_object.reject { |_, value| value.size < 12 }
	bot_users = []
	# assuming each log line has been sorted by time
	possible_bot_users.each do |key,log|
		# need to check in bounds 
		start_index = 0
		end_index = 5

		while end_index <= log.size-1
			# time stamp is within 3 minutes duration
			if (log[start_index]["timestamp"] - log[end_index]["timestamp"]) <= 360
				unique_actions_count = {}
				log[start_index..end_index].each do |row|
					if unique_actions_count[row["action"]].nil?
						unique_actions_count[row["action"]] = 0
					end
					unique_actions_count[row["action"]] += 1
				end
				# checks if any action has more than a certain count
				if unique_actions_count.any? { |key, counts| counts >= 7 }
					bot_users << key
					break
				end
				
			end
			start_index += 1
			end_index += 1
			
		end
	end
	if bot_users.size == 0 
		puts 'No possible bot users!'
	else
		puts 'This is the list of possible bot users: ' + bot_users.sort.join(', ') + '.'
	end
	
end

bot_detector(*ARGV)