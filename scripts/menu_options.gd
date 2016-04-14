
extends Panel

var max_laps = 3

func _ready():
	get_node("Back").connect("pressed", self, "do_back")
	get_node("FullscreenToggle").connect("pressed", self, "do_fullscreen_toggle")
	get_node("MusicVolume").connect("value_changed", self, "do_music_volume_change")
	get_node("EffectsVolume").connect("value_changed", self, "do_effects_volume_change")
	get_node("LapsLess").connect("pressed", self, "do_laps_less")
	get_node("LapsMore").connect("pressed", self, "do_laps_more")

func activate():
	get_node("FullscreenToggle").grab_focus()
	self.show()

func do_back():
	self.hide()
	get_parent().get_parent().activate()

func do_fullscreen_toggle():
	get_parent().get_parent().toggle_window()

func do_music_volume_change(value):
	var player = get_parent().get_parent().get_node("MusicPlayer")
	print(value)
	if (value < -29):
		#Fixme: StreamPlayer gets super unstable when stopping and starting
		#player.stop()
		player.set_volume_db(-80)
	else:
		player.set_volume_db(value)
		if (!player.is_playing()):
			player.play()

func do_effects_volume_change(value):
	Globals.set("effects_volume", value)
	print(value)
	get_node("SamplePlayer").stop_all()
	get_node("SamplePlayer").set_default_volume_db(value)
	var temp = get_node("SamplePlayer").play("chopper_short")
	get_parent().get_parent().update_effects_volumes()

func do_laps_less():
	if (max_laps > 1):
		adjust_laps(-1)

func do_laps_more():
	adjust_laps(1)

func adjust_laps(amount):
	max_laps = max_laps + amount
	get_node("LapLimitLabel").set_text("Max Laps: " + str(max_laps))
	get_parent().get_parent().set_max_laps(max_laps)