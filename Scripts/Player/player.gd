extends CharacterBody2D

@export var mov_speed = 400 # How fast the player will move (pixels/sec).
@export var run_mult = 1.5 # Multiplier when running
var facing: Vector2 = Vector2.DOWN # Direction in which the player is facing
var facingAngle = 0 # Facing Vector as angle in degrees
var isRunning: bool = false
var objectInFront: bool = false
var target = null # Entity inside Interact-Area

# Custom signals
signal object_in_front # Currently unused
signal hit # Currently unused
signal interact(target) # Send player interaction signal, target as argument

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector2.ZERO # The player's movement vector.
	
	isRunning = false
	
	# Create velocity vector from input
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Save latest direction as facing angle
	if velocity != Vector2.ZERO: # Set facing direction to last velocity vector
		facing = velocity
		# Round down to multiples of 90
		facingAngle = (int(rad_to_deg(velocity.angle()) / 90)) * 90
		
	if Input.is_action_pressed("move_run"): # Check for running input
		isRunning = true
	
	# Position player interact hitbox according to facing direction
	$AreaInFront.rotation_degrees = facingAngle
	
	# Handle animations
	if velocity == Vector2.ZERO: # Only idle when not moving
		# Choose animation depending on last facing direction
		if facing.y < 0:
			$AnimatedSprite2D.animation = "idle_up"
		if facing.y > 0:
			$AnimatedSprite2D.animation = "idle_down"
		if facing.x < 0:
			$AnimatedSprite2D.animation = "idle_left"
		if facing.x > 0:
			$AnimatedSprite2D.animation = "idle_right"
	
	if velocity != Vector2.ZERO: # Play movement animation
		if velocity.x != 0: # Prioritize sideway animation on diagonal movement
			if velocity.x < 0:
				$AnimatedSprite2D.animation = "walk_left"
			if velocity.x > 0:
				$AnimatedSprite2D.animation = "walk_right"
		else:
			if velocity.y < 0:
				$AnimatedSprite2D.animation = "walk_up"
			if velocity.y > 0:
				$AnimatedSprite2D.animation = "walk_down"

	if velocity.length() > 0: # Normalize movement vector; constant speed
		velocity = velocity.normalized() * mov_speed
	if isRunning: # Handle running
		velocity *= run_mult
		$AnimatedSprite2D.speed_scale = run_mult # Speed up animation
	else:
		$AnimatedSprite2D.speed_scale = 1 # Reset animation speed

	$AnimatedSprite2D.play() # Play animation
	
	move_and_slide() # Handles movement physics
	checkInteract() # Handles player interaction

func start(pos): # function from tutorial, potentially useless
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
	
func _on_body_entered(body):
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func checkInteract():
	if objectInFront:
		if Input.is_action_pressed("interact"):
			interact.emit(target) # Emit interact signal

# Only keep target as long as it is inside the interact hitbox
func _on_area_in_front_body_entered(body):
	object_in_front.emit() # Emit object in front signal
	objectInFront = true
	target = body

func _on_area_in_front_body_exited(body):
	objectInFront = false
	target = null # Remove target
