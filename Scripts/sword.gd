extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $Sprite2D/Area2D/CollisionShape2D
@onready var sprite_2d = $Sprite2D

@export var damage: float
var follow_offset
@export var follow_speed = 10.0
@export var attack_speed = 1000.0
var is_attacking = false
var player
var next_animation

"""
Called when the node enters the scene tree for the first time.
"""
func _ready():
	collision_shape_2d.disabled = true
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group('player')
	damage = calculate_damage()

"""
Called every frame. 'delta' is the elapsed time since the previous frame.

@param delta (float) delta time.  
"""
func _physics_process(delta):
	await attack(delta)
		
	follow(delta)
	

"""
Makes the sword follow behind the player

@param delta (float) delta time.  
"""
func follow(delta: float): 
	if player: 
		if player.flipped:
			follow_offset = Vector2(-16,0)
			sprite_2d.flip_h = true
			next_animation = "swing_1_flipped"
		else:
			follow_offset = Vector2(16,0)
			sprite_2d.flip_h = false
			next_animation = "swing_1"
			
		var target_position = player.global_position + follow_offset
		global_position = lerp(global_position, target_position, follow_speed * delta)

"""
Given an input from the user, the sword will attack. 

@param delta (float) delta time.
"""
func attack(delta):
	if Input.is_action_just_pressed("attack"):
		is_attacking = true
		collision_shape_2d.disabled = false
		animation_player.play(next_animation)
		
"""
Calculates the damage of any given attack from this sword
"""
func calculate_damage():
	return damage * player.attack + player.level

func _on_animation_player_animation_finished(anim_name):
	animation_player.play("RESET")
	is_attacking = false
	collision_shape_2d.disabled = true


func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)
