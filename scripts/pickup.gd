
extends Node2D

var SPAWN_DELAY = 5

var pickup_type = 0
var spawn_countdown = 0
var ready = true
var pickup_sprite
var particles
var pickup_types = {
					0: Color(0, 1, 0), #health
					1: Color(0, 1, 1), #speed
					2: Color(1, 0, 1), #rotation
					3: Color(1, 1, 0), #fuel
					}

func _ready():
	get_node("Area2D").connect("body_enter", self, "do_collision")
	pickup_sprite = get_node("Sprite")
	particles = get_node("Particles2D")
	init_pickup()
	set_process(true)

func init_pickup():
	#todo: Check what pickups exist and prioritise low frequency ones
	pickup_type = randi() % 4
	if (pickup_types.has(pickup_type)):
		pickup_sprite.set_modulate(pickup_types[pickup_type])
		particles.set_color(pickup_types[pickup_type])
	else:
		print("Unknown pickup type", pickup_type)
	pickup_sprite.show()
	ready = true


func get_type():
	return pickup_type

func _process(delta):
	if (!ready):
		spawn_countdown -= delta
		if (spawn_countdown <= 0):
			init_pickup()

func do_collision(body):
	if (ready):
		body.apply_pickup(self)
		particles.set_emitting(true) #Fixme: Looks like a Godot bug causes the emission to fire twice if its lifetime is less than 1
		ready = false
		pickup_sprite.hide()
		spawn_countdown = SPAWN_DELAY
