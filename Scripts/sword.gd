extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $Sprite2D/Area2D/CollisionShape2D
@onready var sprite_2d = $Sprite2D

@export var swing_angle: float = 90.0      # degrees
@export var swing_speed: float = 500.0    # degrees per second

@export var damage: float
var follow_offset
@export var follow_speed = 10.0
@export var attack_speed = 10.0
var is_attacking = false
var player
var next_animation

@export var offset_right : float = 30
@export var offset_left : float = -30
@export var max_swing_distance := 200.0
var start_position = null
var offset = 0.0

var swinging: bool = false
@export var slash_effect_scene: PackedScene

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
func _physics_process(delta):
	if swinging:
		if global_position.distance_to(start_position) > 1.0:
			swinging = false
	else:
		if player:
			follow(delta)
		collision_shape_2d.disabled = true
		# Only aim at mouse if not swinging
		var mouse_pos = get_global_mouse_position()
		rotation = (mouse_pos - global_position).angle() + deg_to_rad(90)

"""
Swings the sword in the direction of the mouse
"""
func swing():
	if swinging:
		return
	var mouse_pos = get_global_mouse_position()
	start_position = global_position
	swinging = true
	global_position = lerp(global_position, mouse_pos, attack_speed * 0.1) 
	collision_shape_2d.disabled = false
	spawn_slash_effect()
	
		
func follow(delta):
	if player.flipped:
		offset = offset_left
	else:
		offset = offset_right
	var target_pos = player.global_position + Vector2(offset, 0).rotated(player.rotation)
	global_position = lerp(global_position, target_pos, follow_speed * delta)
	

func spawn_slash_effect():
	if slash_effect_scene:
		var effect = slash_effect_scene.instantiate()
		add_child(effect)
		effect.global_position = global_position
		effect.rotation = rotation


func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		swing()


func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)
