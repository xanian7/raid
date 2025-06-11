extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $Sprite2D/Area2D/CollisionShape2D
@onready var sprite_2d = $Sprite2D
@onready var pierce_attack_particles = $PierceAttackParticles
@onready var boomerang_attack_particles = $BoomerangAttackParticles

@export var damage: float

# --- Follow Variables ---
@export var follow_speed: float = 10.0
@export var follow_offset_x: float = 0.0
@export var follow_offset_y: float = 0.0
@export var offset_right : float = 30
@export var offset_left : float = -30

var player

#var is_throwing = false
#var throw_direction = Vector2.ZERO
#var throw_speed = 600
#var throw_target = Vector2.ZERO


# --- State Management ---
enum AttackState { NONE, BOOMERANG, PIERCE, RETURN, BOOMERANG_RETURN }
var attack_state = AttackState.NONE

# --- Boomerang Attack Variables ---
var boomerang_start = Vector2.ZERO
var boomerang_target = Vector2.ZERO
var boomerang_timer = 0.0
var boomerang_duration = 0.4
var boomerang_arc_height = 80
var spin_speed = 1080

# --- Pierce Attack Variables ---
var pierce_start = Vector2.ZERO
var pierce_direction = Vector2.ZERO
var pierce_speed = 900
var pierce_distance = 300
var pierce_travelled = 0.0

var return_speed = 800

"""
Called when the node enters the scene tree for the first time.
"""
func _ready():
	collision_shape_2d.disabled = true
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group('player')

"""
Called every frame. 'delta' is the elapsed time since the previous frame.

@param delta (float) delta time.  
"""
func _process(delta):
	match attack_state:
		AttackState.BOOMERANG:
			_process_boomerang_attack(delta)
		AttackState.PIERCE:
			_process_magic_pierce_attack(delta)
		AttackState.RETURN:
			_process_return_to_player(delta)
		AttackState.BOOMERANG_RETURN:
			_process_boomerang_return_to_player(delta)
		_:
			pass

"""
Normal swing, it will swing the sword in the direction the player is facing
Base attack at the beginning of the game
"""
### setup ###
func swing():
	pass
	
func _process_swing(delta):
	pass

"""
Attack that allows the player to pick the direction the sword attacks in 
flies toward the target and does pierce damage
"""
### setup ###
func magic_pierce_attack():
	#maybe have this glow read
	if attack_state != AttackState.NONE:
		return
	
	pierce_attack_particles.emitting = true
	rotation = (get_global_mouse_position() - global_position).angle() + deg_to_rad(90)
	pierce_start = global_position
	var pierce_target = get_global_mouse_position()
	pierce_direction = (pierce_target - global_position).normalized()
	pierce_travelled = 0.0
	attack_state = AttackState.PIERCE
	collision_shape_2d.disabled = false
	
func _process_magic_pierce_attack(delta):
	var move = pierce_direction * pierce_speed * delta
	global_position += move
	pierce_travelled += move.length()
	if pierce_travelled >= pierce_distance:
		start_return_to_player()

"""
Attack that allows you to hurl the sword like a boomerang and have it return to you
"""
### setup ###
func magic_boomerang_attack():
	if attack_state != AttackState.NONE:
		return
	
	boomerang_start = global_position
	boomerang_target = get_global_mouse_position()
	boomerang_timer - 0.0
	attack_state = AttackState.BOOMERANG
	collision_shape_2d.disabled = false
	boomerang_attack_particles.emitting = true
	
func _process_boomerang_attack(delta):
	boomerang_timer += delta
	var t = boomerang_timer / boomerang_duration
	if t >= 1.0:
		var temp = boomerang_start
		boomerang_start = boomerang_target
		boomerang_target = temp 
		boomerang_timer = 0.0
		start_boomerang_return_to_player()
	else:
		var linear_pos = boomerang_start.lerp(boomerang_target, t)
		var arc_offset = boomerang_arc_height * (-4 * (t - 0.5) * (t - 0.5) + 1)
		global_position = linear_pos + Vector2(0, arc_offset)
		rotation_degrees += spin_speed * delta
		
func start_boomerang_return_to_player():
	attack_state = AttackState.BOOMERANG_RETURN
	boomerang_attack_particles.emitting = false
	collision_shape_2d.disabled = true
	
func _process_boomerang_return_to_player(delta):
	rotation_degrees += spin_speed * delta
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	var move_distance = return_speed * delta
	if distance <= move_distance:
		global_position = player.global_position
		reset_sword()
	else:
		global_position += to_player.normalized() * move_distance
		
"""
When player has enough friendliness with the sword it will follow the player on its own accord
80% friendliness?
"""
func follow(delta):
	if player.flipped:
		follow_offset_x = offset_left
	else:
		follow_offset_x = offset_right
	var target_pos = player.global_position + Vector2(follow_offset_x, 0).rotated(player.rotation)
	global_position = lerp(global_position, target_pos, follow_speed * delta)


func start_return_to_player():
	attack_state = AttackState.RETURN
	pierce_attack_particles.emitting = false
	collision_shape_2d.disabled = true
	
func _process_return_to_player(delta):
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	var move_distance = return_speed * delta
	if distance <= move_distance:
		global_position = player.global_position
		reset_sword()
	else:
		global_position += to_player.normalized() * move_distance
		

"""
Reset sword back to default NONE state
"""
func reset_sword():
	attack_state = AttackState.NONE
	pierce_attack_particles.emitting = false
	collision_shape_2d.disabled = true

"""
Misc inputs go here:
Attacks 
Dashes
Heal
Interact
"""
func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		magic_pierce_attack()
	if event.is_action_pressed("attack_special"):
		magic_boomerang_attack()

"""
Handle attack damage
"""
func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)
