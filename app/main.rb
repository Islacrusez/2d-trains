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
	# render calls
	game_render(args)
	
	return if args.state.game_paused
	# game logic

end

def game_render(args)
	# layout
	x_split = 8
	height = 12
	width = 24
	args.outputs.borders << args.layout.rect(row: 0, col: x_split, w: width - x_split, h: height) # Right 
	args.outputs.borders << args.layout.rect(row: 0, col: 0, w: x_split, h: height) # Left 
	
end