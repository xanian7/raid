extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player")
@onready var collision_shape_2d = $Sprite2D/Area2D/CollisionShape2D

@export var damage: float

# Called when the node enters the scene tree for the first time.
func _ready():
	damage = await calculate_damage()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("attack"):
		animation_player.play("swing_1")

func calculate_damage():
	return damage * player.attack + player.level

func _on_animation_player_animation_finished(anim_name):
	animation_player.play("RESET")


func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)
