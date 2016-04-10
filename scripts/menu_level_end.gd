
extends Panel

func _ready():
	get_node("Menu").connect("pressed", self, "do_back")
	get_node("Continue").connect("pressed", self, "do_next_level")

func populate_stats(player):
	get_node("Time").set_text(get_time_string(player.get_play_time()))
	get_node("Laps").set_text(str(player.get_lap_count()))
	get_node("FastestLap").set_text(get_time_string(player.get_best_lap_time()))
	get_node("Deaths").set_text(str(player.get_death_count()))
	get_node("Fuel").set_text(str(int(player.get_fuel_used())))
	get_node("Pickups").set_text(str(player.get_pickup_count()))

#todo: Merge this with get_time_string in player_hud.gd
func get_time_string(time):
	var minutes = 0
	var seconds = 0
	var milliseconds = 0
	milliseconds = str(int(time * 100) % 100)
	time = int(time)
	var seconds = str(time % 60)
	time = time - (time % 60)
	minutes = str(time)
	return minutes.pad_zeros(2) + ":" + seconds.pad_zeros(2) + ":" + milliseconds.pad_zeros(2)

func do_next_level():
	get_parent().get_parent().load_next_level()
	self.hide()

func do_back():
	self.hide()