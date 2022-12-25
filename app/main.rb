	BORDER	= {primitive_marker: :border}
	SPRITE	= {primitive_marker: :sprite}
	LINE	= {primitive_marker: :line}
	LABEL	= {primitive_marker: :label}
	SOLID 	= {primitive_marker: :solid}

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
	args.state.locomotives << {config: [0, 6, 0], type: :tank, range: 1, max_weight: 45, max_wagons: 6, caboose_required: true, speed: 1}
end

def load_trains(args)
	args.state.trains = []
	
	# dummy train
	loco = args.state.locomotives[0]
	args.state.trains << loco.merge({name: "Little Choo Choo"})


end

def display_trains_viewport(args)
	args.outputs.debug << [10, 25, "Trains viewport"].label

end

def get_button_from_layout(layout, text, method, argument, target, args)
	make_button(layout[:x], layout[:y], layout[:w], layout[:h], text, method, argument, target, args)
end

def make_button(x, y, w, h, text, function, arguments, target, args=$gtk.args)
	clicked = (target.to_s+"_clicked").to_sym
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