
extends Node2D

var checkpoint_id
var particles

func _ready():
	get_node("Area2D").connect("body_enter", self, "do_collision")
	particles = get_node("Particles2D")

func do_collision(body):
	body.advance_checkpoint(self)

func set_id(id):
	checkpoint_id = id

func get_id():
	return checkpoint_id

func do_pass():
	particles.set_emitting(true)