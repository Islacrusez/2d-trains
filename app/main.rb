	BORDER	= {primitive_marker: :border}
	SPRITE	= {primitive_marker: :sprite}
	LINE	= {primitive_marker: :line}
	LABEL	= {primitive_marker: :label}
	SOLID 	= {primitive_marker: :solid}
	SCALE	= 2

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
	args.state.mouse_clicked ||= false
	
	# button locations
	args.state.button_locations = []
	buttons = args.state.button_locations
	(0..5).each do |i|
		buttons << {row: i * 2 + 0.25, col: 1.5, w: 6, h: 1.5}
	end
	
	buttons.map! do |button|
		args.layout.rect(button)
	end
	

	# data structure
	args.state.rendered_buttons = {}
	args.state.clicked_button = {}
	
	load_locomotives(args)
	load_trains(args)
	

	# defaults for game start
	args.state.main_window = :selected
	args.state.selected_type = :station
	args.state.selection = :highgate
	
	args.state.scroll_amount = 0
	
	# for game screen to start on
	args.state.game_state = :playing
end

def main_menu(args)

end

def game_run(args)
	# render calls
	game_render(args)
	case args.state.main_window
		when :selected
		when :stations
		when :trains then display_trains_viewport(args)
		when :network
		when :industries
		when :finances
		when :map
	end
	
	# menu controls
	loc = args.state.button_locations
	args.state.buttons = []
	args.state.buttons << get_button_from_layout(loc[0], "Stations", :select_viewport, :stations, :button_stations, args).merge!(SPRITE)
	args.state.buttons << get_button_from_layout(loc[1], "Trains", :select_viewport, :trains, :button_trains, args).merge!(SPRITE)
	args.state.buttons << get_button_from_layout(loc[2], "Network", :select_viewport, :network, :button_network, args).merge!(SPRITE)
	args.state.buttons << get_button_from_layout(loc[3], "Industries", :select_viewport, :industries, :button_industries, args).merge!(SPRITE)
	args.state.buttons << get_button_from_layout(loc[4], "Finances", :select_viewport, :finances, :button_finances, args).merge!(SPRITE)
	args.state.buttons << get_button_from_layout(loc[5], "Map", :select_viewport, :map, :button_map, args).merge!(SPRITE)
	#args.state.buttons << get_button_from_layout(layout, text, method, argument, target, args)
	
	check_mouse(args.inputs.mouse, args) if args.inputs.mouse.click || args.state.mouse_clicked
	
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
	
	
	args.outputs.sprites << args.state.buttons
end

def select_viewport(to_select, args=$gtk.args)
	args.state.scroll_amount = 0
	args.state.main_window = to_select
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

def load_locomotives(args)
	args.state.locomotives = []
	args.state.locomotives << {config: [2, 4, 2], type: :tank, range: 2, max_weight: 45, max_wagons: 6, caboose_required: true, speed: 1}
	args.state.locomotives << {config: [4, 4, 0], type: :tender, range: 6, max_weight: 80, max_wagons: 8, caboose_required: true, speed: 2}
	
	loco_sprite = {path: 'sprites/2-4-2t.png', w: 38 * SCALE, h: 16 * SCALE}
	args.state.locomotives[0][:sprite] = loco_sprite.merge(SPRITE)
	
	loco_sprite = {path: 'sprites/4-4-0_T.png', w: 57 * SCALE, h: 16 * SCALE}
	args.state.locomotives[1][:sprite] = loco_sprite.merge(SPRITE)
	
end

def load_trains(args)
	args.state.trains = []
	
	# dummy train
	loco = args.state.locomotives[0]
	args.state.trains << loco.merge({name: "Little Choo Choo", wagons: [], weight: 0, location: :highgate, state: :stopped, destination: nil})

	loco = args.state.locomotives[1]
	args.state.trains << loco.merge({name: "Considerably Larger Choo Choo", wagons: [], weight: 0, location: :highgate, state: :stopped, destination: nil})

	args.state.train_state_lookup = {}
	args.state.train_state_lookup[:stopped] = ["Stopped at ", :location]
	args.state.train_state_lookup[:moving] = ["Moving from ", :location, " to ", :destination]
	args.state.train_state_lookup[:ready] = ["Ready to depart from ", :location, " towards ", :destination]
end

def display_trains_viewport(args)
	args.outputs.debug << [10, 25, "Trains viewport"].label
	
	# train controls:
	
	## buy locomotives
	
	## ?
	
	
	###
	
	# get list of trains
	
	args.state.trains_list_locations = []
	elements = args.state.trains_list_locations
	(0..5).each do |i|
		elements << {row: i * 2, col: 8.25, w: 14, h: 2}
	end
	
	elements.map! do |element|
		args.layout.rect(element)
	end
	
	args.outputs.borders << elements
	
	# display individual train in list
	return unless args.state.trains.length > 0
	slots = args.state.trains_list_locations.take(args.state.trains.length)
	args.state.trains_list_display = []
	slots.each_with_index do |slot, i|
		to_display = i + args.state.scroll_amount
		loco = args.state.trains[to_display]
		s_x, s_y, s_max_x, s_max_y = slot[:x], slot[:y], slot[:x] + slot[:w], slot[:y] + slot[:h]
		# s_ denotes start values from which offsets should be calculated
		train_card = []
		display_location = args.state.nodemap[loco[:location]][:display_name]
		train_card << {x: s_x + 15, y: s_max_y - 10, text: loco[:name], size_enum: 2}.merge(LABEL)
		train_card << {x: s_x + 15, y: s_max_y - 35, text: get_loco_state_string(loco, args), size_enum: -1}.merge(LABEL)
		train_card << {x: s_x + 15, y: s_y + 5}.merge(loco[:sprite])
		
		args.state.trains_list_display << train_card
	end
	args.outputs.primitives << args.state.trains_list_display
	
	# list navigation - scrolling?
	args.outputs.borders << args.layout.rect({row: 0, col: 22.5, w: 1.25, h: 12})
	
	
end

def despatch_train(train, args)
	return unless train[:destination] && train[:destination] != train[:location]
	train[:state] = :moving
end

def set_destination(train, destination, args)
	return unless train[:state] == :ready || train[:state] == :stopped 
	return if train[:location] == destination
	return if args.state.nodemap[train[:location]].include?(destination)
	raise "Attempted to set invalid destination, destination #{destination} is not a Symbol" unless destination.is_a?(Symbol)
	train[:destination] = destination
	train[:state] = :ready
end

def select_train(train, args)

end

def display_loc(place_key, args)
	args.state.nodemap[loco[:place]][:display_name]
end

def get_loco_state_string(loco, args)
	items_to_string = args.state.train_state_lookup[loco[:state]].map do |item|
		case item
			when String then item
			when Symbol  then args.state.nodemap[loco[item]][:display_name]
			else raise "Get Loco State String Case: Error, invalid type received"
		end
	end
	string = ""
	items_to_string.each do |item|
		string << item
	end
	string
end

def get_button_from_layout(layout, text, method, argument, target, args)
	make_button(layout[:x], layout[:y], layout[:w], layout[:h], text, method, argument, target, args)
end

def make_button(x, y, w, h, text, function, arguments, target, args=$gtk.args)
	clicked = (target.to_s+"_clicked").to_s.to_sym
	unless args.state.rendered_buttons[target]
		make_clicked_button(w, h, text, clicked, args)
		text_w, text_h = $gtk.calcstringbox(text)
		args.render_target(target).height = h
		args.render_target(target).width = w
		out_x = x
		out_y = y
		x = 0
		y = 0
		args.render_target(target).borders << [x, y, w, h]
		args.render_target(target).borders << [x, y+1, w-1, h-1]
		args.render_target(target).borders << [x+2, y+2, w-4, h-4]
		args.render_target(target).labels << [x + (w - text_w) / 2, y + (h + text_h) / 2 - 1, text]
	end
	args.state.rendered_buttons ||= {}
	args.state.rendered_buttons[target] = true
	out_x ||= x
	out_y ||= y
	target = clicked if args.state.clicked_button_key == target
	{x: out_x, y: out_y, w: w, h: h, path: target, arguments: arguments, function: method(function)}
end

def make_clicked_button(w, h, text, target, args=$gtk.args)
	text_w, text_h = $gtk.calcstringbox(text)
	args.render_target(target).height = h
	args.render_target(target).width = w
	x = 0
	y = 0
	args.render_target(target).borders << [x, y, w, h]
	args.render_target(target).borders << [x+1, y, w-1, h-1]
	args.render_target(target).borders << [x+2, y+2, w-4, h-4]
	args.render_target(target).labels << [x + (w - text_w) / 2, y + (h + text_h) / 2 - 1, text]
end

def check_mouse(mouse, args)
	args.state.buttons.each do |button|
		if mouse.inside_rect?(button)
			args.state.mouse_clicked = true
			args.state.clicked_button = button
			args.state.clicked_button_key = button[:path]
			break
		end
	end unless args.state.mouse_clicked
	on_button = false
	if args.state.mouse_clicked && mouse.inside_rect?(args.state.clicked_button)
		args.state.clicked_button_key = args.state.clicked_button[:path]
		on_button = true
	end
	args.state.clicked_button_key = false unless on_button
	if mouse.up
		args.state.clicked_button[:function].call(args.state.clicked_button[:arguments], args) if on_button
		args.state.mouse_clicked = false
		args.state.clicked_button = nil
		args.state.clicked_button_key = nil
	end
end