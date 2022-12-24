def tick(args)
	init(args) unless args.state.game_state
	case args.state.game_state
		when :menu then main_menu(args)
		when :settings then 
		when :playing	then game_run(args)
		else raise "Invalid Game State! Fatal!"
	end
end

def init(args)


	args.state.game_state = :playing
end

def main_menu(args)

end

def game_run(args)


end