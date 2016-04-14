
extends RigidBody2D

var MAX_SPEED = 15
var MAX_ROT = 5
var DEATH_LIMIT = 1.2
var ROT_SPEED = 0.25
var ACCEL_SPEED = 0.25
var FUEL_SPEED = 5
var MAX_HEALTH = 3
var MAX_FUEL = 100
var CHECKPOINT_FUEL_BONUS = 25
var BONUS_DURATION = 5

var bonus_speed = 0
var bonus_rotation = 0
var bonus_countdown = 0
var bonus_active = false

var sprite_chasis
var sprite_blades
var particle_impact
var particle_explosion
var particle_lap
var canvas_hud

var user_input = Vector2(0, 0)
var angular_damp
var current_acceleration = 0
var current_rotation = 0
var current_health = MAX_HEALTH
var current_fuel = MAX_FUEL
var dying = false
var deathTime = 0
var spawn_pos
var checkpoint_counter = 1
var next_checkpoints = {}
var lap_counter = -1
var play_time = 0
var best_lap_time = 0
var checkpoint_start_time = 0
var death_count = 0
var pickup_count = 0
var fuel_used = 0
var max_laps
var loader

func _ready():
	var h = preload("res://objects/player_hud.xscn")
	canvas_hud = h.instance()
	self.add_child(canvas_hud)
	canvas_hud.update_health_indicator(current_health)
	canvas_hud.update_lap_indicator(0)
	canvas_hud.update_pickup_indicator("")
	canvas_hud.update_fuel_indicator(current_fuel)
	sprite_chasis = get_node("ChopperChasis")
	sprite_blades = get_node("ChopperBlades")
	particle_impact = get_node("Impact")
	particle_explosion = get_node("Explosion")
	particle_lap = get_node("Lap")
	angular_damp = self.get_angular_damp()
	set_process_input(true)
	set_process(true)

func init_player(_loader, _max_laps):
	loader = _loader
	max_laps = _max_laps
	spawn_pos = self.get_pos()
	set_next_checkpoint(1)
	for c in next_checkpoints.keys():
		self.set_rot(self.get_angle_to(c.get_pos()) - PI)
		break
	get_node("StreamPlayer").set_volume_db(Globals.get("effects_volume"))
	get_node("StreamPlayer").set_paused(false)

func set_max_laps(_max_laps):
	max_laps = _max_laps

func update_effects_volume():
	var v = Globals.get("effects_volume")
	get_node("StreamPlayer").set_volume_db(v)
	var s = get_node("SamplePlayer")
	for i in range(s.get_polyphony()):
		if (s.is_voice_active(i - 1)):
			s.set_volume_db(i - 1, v)

func get_fuel_used():
	return fuel_used

func get_death_count():
	return death_count

func get_play_time():
	return play_time

func get_best_lap_time():
	return best_lap_time

func get_lap_count():
	return lap_counter

func get_pickup_count():
	return pickup_count

func reset_bonuses():
	bonus_speed = 0
	bonus_rotation = 0
	bonus_countdown = 0
	bonus_active = false
	canvas_hud.update_pickup_indicator("")

func apply_pickup(pickup):
	reset_bonuses()
	if (pickup.get_type() == 0):
		current_health = MAX_HEALTH
		canvas_hud.update_health_indicator(current_health)
		print("Restoring health")
	elif (pickup.get_type() == 1):
		bonus_speed = 10
		canvas_hud.update_pickup_indicator("Speed Bonus")
		print("Increasing speed")
	elif (pickup.get_type() == 2):
		bonus_rotation = 5
		canvas_hud.update_pickup_indicator("Rotation Bonus")
		print("Increasing rotation")
	elif (pickup.get_type() == 3):
		current_fuel = MAX_FUEL
		canvas_hud.update_fuel_indicator(current_fuel)
		print("Restoring fuel")
	bonus_countdown = BONUS_DURATION
	pickup_count += 1
	get_node("SamplePlayer").play("pickup")

func _integrate_forces(state):
	for i in range(state.get_contact_count()):
		do_collision(state.get_contact_local_pos(i))

	if (!dying):
		if (user_input.x != 0):
			current_rotation += user_input.x * ROT_SPEED
			if (current_rotation > MAX_ROT):
				current_rotation = MAX_ROT + bonus_rotation
			elif (current_rotation < - MAX_ROT):
				current_rotation = - MAX_ROT - bonus_rotation
			self.set_angular_velocity(current_rotation)
		else:
			current_rotation = 0

		if (user_input.y != 0):
			current_acceleration += user_input.y * ACCEL_SPEED
			var v = Vector2(0, current_acceleration)
			if (v.length() > 1):
				v = v.normalized()
			v = v * (MAX_SPEED + bonus_speed)
			self.apply_impulse(- v.rotated(self.get_rot()), v.rotated(self.get_rot()))
		else:
			current_acceleration = 0
	else:
		self.set_angular_damp(0)
		self.set_scale(self.get_scale() - Vector2(deathTime / 4, deathTime / 4))

func do_collision(impact_pos):
	get_node("SamplePlayer").play("crash")
	particle_impact.set_global_pos(impact_pos)
	particle_impact.set_rot(self.get_pos().angle_to(impact_pos))
	particle_impact.set_emitting(true)

	if (dying):
		#explode!
		explode()
	else:
		current_health -= 1
		canvas_hud.update_health_indicator(current_health)
		if (current_health <= 0):
			var v = self.get_pos() - impact_pos
			self.apply_impulse(self.get_pos(), v * 2.5)
			die()

func set_next_checkpoint(id):
	#Todo: next_checkpoint should be an array of checkpoints with the appropriate index
	for c in next_checkpoints.keys():
		self.remove_child(next_checkpoints[c])
		if (next_checkpoints.has(c)):
			#Todo: This is firing non-fatal errors?
			next_checkpoints[c].queue_free()
	next_checkpoints.clear()
	for c in Globals.get("checkpoint_list"):
		if (c.get_id() == id):
			next_checkpoints[c] = get_node("ChopperGuide").duplicate()
			self.add_child(next_checkpoints[c])
			next_checkpoints[c].show()

func advance_checkpoint(checkpoint):
	print("Checking checkpoint", checkpoint.get_id() , ". Expecting ", checkpoint_counter)
	if (checkpoint.get_id() == checkpoint_counter):
		get_node("SamplePlayer").play("checkpoint")
		spawn_pos = checkpoint.get_pos()
		checkpoint.do_pass()
		if (checkpoint_counter == 1):
			lap_counter += 1
			var t = play_time - checkpoint_start_time
			if (lap_counter > 0):
				if (t < best_lap_time || best_lap_time == 0):
					best_lap_time = t
					print("New best lap ", t)
				checkpoint_start_time = play_time
				get_node("SamplePlayer").play("lap")
				particle_lap.set_emitting(true)
			if (lap_counter >= max_laps):
				do_win()
			print("Lap ", lap_counter, " completed")
			canvas_hud.update_lap_indicator(lap_counter)
		if (checkpoint_counter >= Globals.get("last_checkpoint")):
			checkpoint_counter = 1
		else:
			checkpoint_counter += 1
		set_next_checkpoint(checkpoint_counter)
		current_fuel += CHECKPOINT_FUEL_BONUS
		if (current_fuel > MAX_FUEL):
			current_fuel = MAX_FUEL
		canvas_hud.update_fuel_indicator(current_fuel)

func _process(delta):
	play_time += delta
	canvas_hud.update_time_indicator(play_time)
	for c in next_checkpoints.keys():
		next_checkpoints[c].set_rot(self.get_angle_to(c.get_pos()))
	sprite_blades.set_rot(-self.get_rot() + play_time * 8)

	if (!dying):
		if (user_input.y != 0):
			current_fuel -= delta * FUEL_SPEED
			fuel_used += delta * FUEL_SPEED
			canvas_hud.update_fuel_indicator(current_fuel)

		if (bonus_active):
			if (bonus_countdown <= 0):
				reset_bonuses()
			else:
				bonus_countdown -= delta
	else:
		#Todo: Allow partial user input to influence movement during death?
		deathTime = deathTime + delta
		if (deathTime > DEATH_LIMIT):
			reset_bonuses()
			dying = false
			deathTime = 0
			current_health = MAX_HEALTH
			current_fuel = MAX_FUEL
			canvas_hud.update_health_indicator(current_health)
			canvas_hud.update_fuel_indicator(current_fuel)
			self.set_linear_velocity(Vector2(0,0))
			self.set_angular_velocity(0)
			self.set_angular_damp(angular_damp)
			self.set_pos(spawn_pos)
			self.set_rot(0)
			for c in next_checkpoints.keys():
				self.set_rot(self.get_angle_to(c.get_pos()) - PI)
				print(self.get_rot())
				break
			sprite_blades.show()
			sprite_chasis.show()
			get_node("StreamPlayer").set_volume_db(Globals.get("effects_volume"))
			get_node("StreamPlayer").set_paused(false)
			#Todo: Maybe have a nice sound/effect here when we're done dying?
			death_count += 1

	if (current_fuel <= 0):
		die()

func _input(event):
	#todo: User bindings
	if (event.type == InputEvent.KEY):
		if (event.is_action_pressed("ui_down") || event.is_action_released("ui_up")):
			user_input.y += 1
		if (event.is_action_pressed("ui_up") || event.is_action_released("ui_down")):
			user_input.y -= 1
		if (event.is_action_pressed("ui_right") || event.is_action_released("ui_left")):
			user_input.x += 1
		if (event.is_action_pressed("ui_left") || event.is_action_released("ui_right")):
			user_input.x -= 1

	elif (event.type == InputEvent.JOYSTICK_MOTION):
		if (event.axis == 2):
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
	get_node("StreamPlayer").set_volume_db(-80)
	get_node("StreamPlayer").set_paused(true)
	dying = true

func explode():
	get_node("SamplePlayer").play("explode")
	particle_explosion.set_emitting(true)
	self.set_linear_velocity(Vector2(0,0))
	self.set_angular_velocity(0)
	sprite_blades.hide()
	sprite_chasis.hide()
	self.set_sleeping(true)
	deathTime = DEATH_LIMIT - particle_explosion.get_lifetime()

func do_win():
	print("Winning, with " + str(lap_counter) + "of " + str(max_laps))
	loader.end_level(self)