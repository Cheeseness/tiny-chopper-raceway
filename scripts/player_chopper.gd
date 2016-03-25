
extends RigidBody2D

var MAX_SPEED = 10
var MAX_ROT = 5
var DEATH_LIMIT = 1.2

var ROT_SPEED = 0.25
var ACCEL_SPEED = 0.25

var user_input = Vector2(0, 0)
var current_acceleration = 0
var current_rotation = 0
var sprite_chasis
var sprite_blades
var dying = false
var deathTime = 0

func _ready():
	sprite_chasis = get_node("ChopperChasis")
	sprite_blades = get_node("ChopperBlades")
	set_process_input(true)
	set_process(true)

func _process(delta):
	if (!dying):
		#Allow partial user input to influence movement during crash?
		if (user_input.x != 0):
			current_rotation += user_input.x * ROT_SPEED
			if (current_rotation > MAX_ROT):
				current_rotation = MAX_ROT
			elif (current_rotation < - MAX_ROT):
				current_rotation = - MAX_ROT
			self.set_angular_velocity(current_rotation)
		else:
			current_rotation = 0
		if (user_input.y != 0):
			current_acceleration += user_input.y * ACCEL_SPEED
			var v = Vector2(0, current_acceleration)
			if (v.length() > 1):
				v = v.normalized()
			v = v * MAX_SPEED
			self.apply_impulse(- v.rotated(self.get_rot()), v.rotated(self.get_rot()))
		else:
			current_acceleration = 0
		sprite_blades.set_rot((sprite_blades.get_rot()) + delta * 10)
	else:
		deathTime = deathTime + delta
		self.set_rot(self.get_rot() + (0.25 * deathTime))
		if (deathTime > DEATH_LIMIT):
			dying = false
			deathTime = 0
			self.set_rot(0)
			self.set_linear_velocity(Vector2(0,0))

func _input(event):
	if (event.type == InputEvent.KEY):
		if (event.is_action_pressed("ui_down")):
			user_input.y = 1
		if (event.is_action_pressed("ui_up")):
			user_input.y = -1
		if (event.is_action_pressed("ui_right")):
			user_input.x = 1
		if (event.is_action_pressed("ui_left")):
			user_input.x = -1
		if (event.is_action_released("ui_down") || event.is_action_released("ui_up")):
			user_input.y = 0
		if (event.is_action_released("ui_left") || event.is_action_released("ui_right")):
			user_input.x = 0

	elif (event.type == InputEvent.JOYSTICK_MOTION):
		if (event.axis == 0):
			if (abs(event.value) < 0.1):
				user_input.x = 0
			else:
				user_input.x = event.value
		if (event.axis == 1):
			if (abs(event.value) < 0.1):
				user_input.y = 0
			else:
				user_input.y = event.value

func die():
	#todo: add some nice effects
	dying = true