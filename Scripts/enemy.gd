extends CharacterBody2D

@onready var collision_shape_2d = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var max_health: float 
@export var current_health: float 
@export var defense: float
@export var attack: float

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemy")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	
func take_damage(damage):
	current_health -= damage
	print(current_health)
