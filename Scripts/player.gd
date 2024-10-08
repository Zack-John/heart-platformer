extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

@onready var starting_position = global_position

@export var movement_data : PlayerMovementData
#@export var SPEED = 100.0
#@export var JUMP_VELOCITY = -300.0
#@export var ACCELERATION = 600
#@export var FRICTION = 600

var air_jump = false
var just_wall_jumped = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


### MAIN PROCESSES ###
func _physics_process(delta):
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	
	var input_axis = Input.get_axis("move_left", "move_right")
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	
	update_animations(input_axis)
	
	var was_on_floor = is_on_floor() # check if the player was on the floor before applying movement
	move_and_slide()
	
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	
	if just_left_ledge:
		coyote_jump_timer.start()
	
	# reset wall jump tracker for this frame
	just_wall_jumped = false
	
	# DEBUG: switch movement data on key presses
	if Input.is_action_just_pressed("ui_up"):
		movement_data = load("res://Resources/FasterMovementData.tres")
	if Input.is_action_just_pressed("ui_down"):
		movement_data = load("res://Resources/DefaultMovementData.tres")


### HELPER FUNCTIONS ###
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func handle_acceleration(input_axis, delta):
	if not is_on_floor():
		return
	
	if input_axis:
		#velocity.x = direction * SPEED
		velocity.x = move_toward(velocity.x, input_axis * movement_data.speed, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if is_on_floor():
		return
	
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func handle_wall_jump():
	if not is_on_wall_only():
		return
	
	var wall_normal = get_wall_normal() # wall_normal is a vector pointing AWAY from the wall
	
	# NOTE: if i used the jump button instead, could get rid of wall_normal vector and direction checks
	if Input.is_action_just_pressed("move_left") and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true
		
	if Input.is_action_just_pressed("move_right") and wall_normal == Vector2.RIGHT:
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true

func handle_jump():
	if is_on_floor():
		air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
	
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < (movement_data.jump_velocity / 2):
			velocity.y = movement_data.jump_velocity / 2
	
		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			velocity.y = (movement_data.jump_velocity * 0.80)
			air_jump = false
	
func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")

# NOTE: this was connected via the editor, hence no connect() call anywhere
func _on_hazard_detector_area_entered(area):
	# respawn player back at the starting position
	global_position = starting_position
