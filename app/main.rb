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
	load_nodemap(args)

	# defaults for game start
	args.state.main_window = :selected
	args.state.selected_type = :station
	args.state.selection = :highgate
	
	# for game screen to start on
	args.state.game_state = :playing
end

def main_menu(args)

end

def game_run(args)
	# render calls
	game_render(args)
	
	# menu controls
	
	
	
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

def game_pause!(args=$gtk.args)
	args.state.game_paused = true
end

def game_unpause!(args=$gtk.args)
	args.state.game_paused = false
end

def game_pause_toggle!(args=$gtk.args)
	args.state.game_paused ? game_unpause! : game_pause!
end

def load_nodemap(args)
	args.state.nodemap = {}
	args.state.nodemap.default = { connects: [] }
	
	# test map
	
	args.state.nodemap[:byglass] = {type: :platform, connects: [:highgate, :wayfield], facilities: []}
	args.state.nodemap[:springwyn] = {type: :station, connects: [:highgate], facilities: []}
	args.state.nodemap[:westmill] = {type: :station, connects: [:highgate], facilities: []}
	args.state.nodemap[:highgate] = {type: :station, connects: [:springwyn, :westmill, :byglass], facilities: [:office, :warehouse, :water_tower, :coal_bunker, :siding]}
	args.state.nodemap[:wayfield] = {type: :platform, connects: [:byglass, :redford, :woodbank], facilities: []}
	args.state.nodemap[:woodbank] = {type: :platform, connects: [:wayfield], facilities: []}
	args.state.nodemap[:redford] = {type: :station, connects: [:wayfield], facilities: [:siding, :water_tower, :coal_bunker]}
	
	args.state.nodemap.each do |key, value|
		value[:display_name] = key.to_s.capitalize!
	end
	
end