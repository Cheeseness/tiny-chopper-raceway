
extends Node

var player_instances = []
var level_map
var blank_cell
var hide_tiles = false
var level_running = false
var current_level = null
var current_level_name
var max_laps = 3 #todo: Store this in some level metadata so that levels can have different lap limits

func _ready():
	pass

func is_level_running():
	return level_running

func get_player_instances():
	return player_instances

func end_level(player):
	level_running = false
	get_parent().end_level(player)

func set_max_laps(_max_laps):
	max_laps = _max_laps
	for p in player_instances:
		p.set_max_laps(max_laps)
	print("Updating max_laps to " , max_laps)

func unload_level():
	print("Unloading level " + str(current_level_name))
	if (current_level != null):
		remove_child(current_level)
		current_level.queue_free()
	current_level_name = null
	level_running = false

func load_level(level_name):
	if (current_level == null):
		unload_level()
	print("Loading level " + level_name)
	current_level_name = level_name
	var l = load("res://levels/" + level_name + ".xscn")
	current_level = l.instance();
	add_child(current_level)
	level_map = current_level.get_node("TileMap")
	replace_level_tiles()
	for p in player_instances:
		p.init_player(self, max_laps)
	level_running = true

func reload_level():
	var temp = current_level_name
	unload_level()
	load_level(temp)

func replace_level_tiles():
	#There's no cell by that name, but should a default "empty" cell be needed, this lets us make use of one
	blank_cell = level_map.get_tileset().find_tile_by_name("Clear")
	hide_tiles = true

	var cell_list = level_map.get_used_cells()
	var player_chopper = preload("res://objects/player_chopper.xscn")
	var checkpoint = preload("res://objects/checkpoint.xscn")
	var pickup = preload("res://objects/pickup.xscn")
	var last_checkpoint = 0
	var pickup_count = 0
	var checkpoint_list = []
	var pickup_list = []
	var obstacles_small = []
	var obstacles_large = []
	#todo: Interrogate file system and populate list based on obstacles scenes found
	obstacles_small.append(preload("res://objects/obstacle_small1.xscn"))
	obstacles_small.append(preload("res://objects/obstacle_small2.xscn"))
	obstacles_large.append(preload("res://objects/obstacle_large1.xscn"))
	obstacles_large.append(preload("res://objects/obstacle_large2.xscn"))

	for c in cell_list:
		var cell_type = level_map.get_tileset().tile_get_name(level_map.get_cell(c[0], c[1]))

		for i in range(9):
			if (cell_type == "Checkpoint" + str(i)):
				var cp = replace_tile(checkpoint, c, hide_tiles)
				cp.set_id(i)
				if (i > last_checkpoint):
					last_checkpoint = i
				checkpoint_list.append(cp)

		if (cell_type == "PlayerSpawn"):
			player_instances.append(replace_tile(player_chopper, c, hide_tiles))
		elif (cell_type == "Pickup"):
			var p = replace_tile(pickup, c, hide_tiles)
			pickup_list.append(p)
			pickup_count += 1
		elif (cell_type == "ObstacleS"):
			var o = obstacles_small[randi() % obstacles_small.size()]
			replace_tile(o, c, hide_tiles)
		elif (cell_type == "ObstacleL"):
			var o = obstacles_large[randi() % obstacles_large.size()]
			replace_tile(o, c, hide_tiles)
		else:
			pass
	print("Level generation complete...")
	print("\tPlayer Spawns: ", player_instances.size())
	print("\tCheckpoints: ", checkpoint_list.size())
	print("\tPickups: ", pickup_count)
	Globals.set("checkpoint_list", checkpoint_list)
	Globals.set("pickup_list", pickup_list)
	Globals.set("last_checkpoint", last_checkpoint)

func replace_tile(node, cell, blank = true):
	if blank == true:
		level_map.set_cell(cell[0], cell[1], blank_cell, false, false, false)
	var n = node.instance()
	level_map.get_parent().add_child(n)
	n.set_pos(level_map.map_to_world(cell, false) + Vector2(128, 128)) #Offset by 128,128 so that our replaced entities will be nicely centred
	return n