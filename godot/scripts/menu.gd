
extends Node

var screenshot = false
var level_list = [
					"simple_circuit",
					"figure8",
					"scavenger_hunt",
					"choose_your_own_adventure",
				]
var level_loader
var current_level_index = 0
var menu_options
var menu_credits
var menu_level_select
var menu_level_end

func _ready():
	#We probably don't need a node to attach the level_loader script to (it'd be better off as a class that's instantiated)
	#For now, this is a good example of how to instantiate a generic node and attach a script
	level_loader = Node.new()
	level_loader.set_script(load("res://scripts/level_loader.gd"))
	add_child(level_loader)
	#Todo: load a test level in the background and pan across it while at the main menu?

	#We have some hefty resources in our tilemap. Let's pre-load them so that level load times are consistent
	preload("res://tilemaps/tilemap.xml")

	var temp = preload("res://menus/options.xscn")
	menu_options = temp.instance()
	temp = preload("res://menus/credits.xscn")
	menu_credits = temp.instance()
	temp = preload("res://menus/level_chooser.xscn")
	menu_level_select = temp.instance()
	menu_level_select.populate_level_list(level_list)
	temp = preload("res://menus/level_end.xscn")
	menu_level_end = temp.instance()
	hide_sub_menus()
	get_node("CanvasLayer").add_child(menu_options)
	get_node("CanvasLayer").add_child(menu_credits)
	get_node("CanvasLayer").add_child(menu_level_select)
	get_node("CanvasLayer").add_child(menu_level_end)

	get_node("CanvasLayer/Menu/NewGame").connect("pressed", self, "do_new_game")
	get_node("CanvasLayer/Menu/Restart").connect("pressed", self, "do_restart_level")
	get_node("CanvasLayer/Menu/SelectLevel").connect("pressed", self, "do_level_select")
	get_node("CanvasLayer/Menu/Options").connect("pressed", self, "do_options")
	get_node("CanvasLayer/Menu/Credits").connect("pressed", self, "do_credits")
	get_node("CanvasLayer/Menu/Website").connect("pressed", self, "do_website")
	get_node("CanvasLayer/Menu/Resume").connect("pressed", self, "do_unpause")
	get_node("CanvasLayer/Menu/Quit").connect("pressed", self, "do_quit")
	get_node("CanvasLayer/Menu/NewGame").grab_focus()

	Globals.set("effects_volume", -5)

	set_process(true)
	set_process_input(true)

func end_level(player):
	do_pause()
	menu_level_end.populate_stats(player)
	menu_level_end.activate()
	if (current_level_index >= level_list.size() - 1):
		menu_level_end.set_last_level()

func load_level(level_index):
	if (level_index < level_list.size() && level_index >= 0):
		level_loader.unload_level()
		level_loader.load_level(level_list[level_index])
		current_level_index = level_index
		do_unpause()
	else:
		print("Trying to load a level that doesn't exist!")

func load_next_level():
	current_level_index += 1
	if (current_level_index < level_list.size()):
		level_loader.unload_level()
		level_loader.load_level(level_list[current_level_index])
		do_unpause()
	else:
		print("Can't continue to next level - there are none!")

func set_max_laps(max_laps):
	level_loader.set_max_laps(max_laps)

func update_effects_volumes():
	var pi = level_loader.get_player_instances()
	for i in pi:
		i.update_effects_volume()

func _process(delta):
	if (screenshot):
		var shot = get_node("/root").get_screen_capture()
		if !shot.empty():
			var d = OS.get_date()
			var t = OS.get_time()
			shot.save_png("user://screenshot" + str(d["year"]) + "-" + str(d["month"]+ 1) + "-" + str(d["day"]) + "_" + str(t["hour"]) + "-" + str(t["minute"]) + "-" + str(t["second"]) + ".png")
			screenshot = false
			print("Screenshot saved. Good luck finding it!")
		else:
			print("Screenshot not ready yet. Waiting...")

func _input(event):
	if (event.is_action_pressed("pause")):
		print("Got pause event...")
		if (get_tree().is_paused()):
			do_unpause()
		else:
			do_pause()

	elif (event.is_action_pressed("toggleWindowed")):
		toggle_window()

	elif (event.is_action_pressed("screenshot")):
		get_node("/root").queue_screen_capture()
		screenshot = true

func do_new_game():
	do_unpause()
	level_loader.load_level(level_list[0])

func do_options():
	hide_sub_menus()
	menu_options.activate()

func do_credits():
	hide_sub_menus()
	menu_credits.activate()

func do_level_select():
	hide_sub_menus()
	menu_level_select.activate()

func do_restart_level():
	level_loader.reload_level()
	do_unpause()

func activate():
	if (level_loader.is_level_running()):
		get_node("CanvasLayer/Menu/Resume").grab_focus()
	else:
		get_node("CanvasLayer/Menu/NewGame").grab_focus()

func do_pause():
	print("Pausing")
	get_tree().set_pause(true)
	reset_buttons()
	get_node("CanvasLayer/Menu").show()

func do_unpause():
	print("Unpausing")
	get_tree().set_pause(false)
	reset_buttons()
	hide_sub_menus()
	get_node("CanvasLayer/Menu").hide()
	get_node("CanvasLayer/Splash").hide()

func reset_buttons():
	if (level_loader.is_level_running()):
		get_node("CanvasLayer/Menu/Resume").show()
		get_node("CanvasLayer/Menu/NewGame").hide()
		get_node("CanvasLayer/Menu/Restart").show()
		get_node("CanvasLayer/Menu/Resume").grab_focus()
	else:
		get_node("CanvasLayer/Menu/Resume").hide()
		get_node("CanvasLayer/Menu/Restart").hide()
		get_node("CanvasLayer/Menu/NewGame").show()
		get_node("CanvasLayer/Menu/NewGame").grab_focus()

func hide_sub_menus():
	menu_options.hide()
	menu_credits.hide()
	menu_level_select.hide()
	menu_level_end.hide()

func do_quit():
	get_tree().quit()

func do_website():
	var url = "http://cheeseness.itch.io/tiny-chopper-raceway"
	print("Attempting to launch URL: ", url)
	OS.shell_open(url)

func toggle_window():
	#Fixme: This tends to be a little crashy if few system resources are available
	if(OS.is_window_fullscreen()):
		menu_options.get_node("FullscreenToggle").set_text("Fullscreen Mode")
		OS.set_window_fullscreen(false)
		OS.set_window_maximized(false)
		OS.set_window_size(Vector2(1280, 720))
	else:
		OS.set_window_fullscreen(true)
		menu_options.get_node("FullscreenToggle").set_text("Windowed Mode")
