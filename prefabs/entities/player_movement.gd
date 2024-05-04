extends CharacterBody2D

@export_category("Movement")
@export var move_speed = 300.0
var speed = move_speed
@export var cyote_time = 1
@export var deceleration = 2000.0

@export_category("Dash")
@export var dash_speed = 300.0
@export var dash_time = 0.3
var dash_used = false

@export_category("Jump")
@export var jump_velocity = -400.0
@export var gravity = 980


func _physics_process(delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_pressed("jump") and is_on_floor():
		handle_jump()
		
	if Input.is_action_just_pressed("dash") and not dash_used and speed <= move_speed:
		handle_dash()

	if direction:
		velocity.x = direction * speed
	elif velocity.x != 0:
		var deceleration_amount = deceleration * delta
		if abs(velocity.x) <= deceleration_amount:
			velocity.x = 0
		else:
			velocity.x -= sign(velocity.x) * deceleration_amount
	
	if abs(velocity.x) <= 100:
		speed = move_speed

	move_and_slide()


func handle_jump():
	velocity.y = jump_velocity


func handle_dash():
	dash_used = true
	speed += dash_speed
	await get_tree().create_timer(dash_time).timeout
	dash_used = false
