extends RigidBody2D # TODO: Maybe replace RigidBody with CharacterBody
@export var mov_speed = 50
@export var mov_interval = 1
var time = 0
var velocity = Vector2.ZERO

signal death


# Called when the node enters the scene tree for the first time.
func _ready():
	set_linear_damp(1) # Linear damp for physics
	add_to_group("enemies") # Adds to group, currently unused

func die():
	queue_free() # Remove object
	death.emit() # Send death signal

func start(pos): # function from tutorial, potentially useless
	position = pos
	show()
	$CollisionShape2D.disabled = false

func ranDir() -> Vector2: # Create vector with random direction
	var velocity = Vector2.ZERO
	velocity.x = (randi() % 3) - 1 # random int [-1, 1]
	velocity.y = (randi() % 3) - 1
	return velocity

# Called every frame
func _process(delta):
	
	# Move every random x seconds
	# TODO: Replace with godot native timer
	time -= delta # countdown
	if time <= 0: # every x seconds
		velocity = Vector2.ZERO
		
		if !(randi() % 4): # 25% chance of moving
			velocity = ranDir() # new vector
			velocity = velocity.normalized() * mov_speed
			
		time = mov_interval # restart timer
	
	
	
	if velocity == Vector2.ZERO: # Handle idle and move animation
		$AnimatedSprite2D.animation = "idle"
	else:
		$AnimatedSprite2D.animation = "move"

	# Add force to RigidBody
	apply_central_force(velocity)
	
	# Play animation
	$AnimatedSprite2D.play()

func _on_player_interact():
	die()
