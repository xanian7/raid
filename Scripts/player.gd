extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

@export var attack: float
@export var level: int
@export var max_health: float
@export var current_health: float
@export var defense: float

@export var flipped: bool


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready():
	self.add_to_group("player")


func _physics_process(delta):
	move_player(delta)
	
func move_player(delta):
	var direction = Vector2.ZERO
	direction = Vector2(
		(Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * 2,
		(Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	).normalized()
	if direction.x:
		velocity.x = direction.x * SPEED
		if direction.x > 0:
			animated_sprite_2d.flip_h = false
			flipped = true
		else: 
			animated_sprite_2d.flip_h = true
			flipped = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
			
	if direction.y:
		velocity.y = direction.y * SPEED 
	else: 
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
