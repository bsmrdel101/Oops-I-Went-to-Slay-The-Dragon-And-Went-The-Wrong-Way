extends CharacterBody2D

@export_category("Movement")
@export var move_speed = 300.0
@export var cyote_time = 0.1
@export var deceleration = 2000.0
@export var max_speed = 1000.0

@export_category("Dash")
@export var dash_speed = 300.0
@export var dash_time = 0.3

@export_category("Jump")
@export var jump_velocity = -650.0
@export var gravity = 980

@export_category("Dive")
@export var dive_boost = 300.0
@export var dive_jump_window = 0.2

@export_category("References")
@onready var anim = $AnimatedSprite2D

var speed = move_speed
var dash_used = false
var coyote_timer = 0.0
var is_diving = false
var dive_jump_timer = 0.0
var direction


func _process(delta):
	anim.play("idle")
	
	if is_on_floor():
		coyote_timer = cyote_time
	else:
		coyote_timer -= delta
	
	direction = Input.get_axis("move_left", "move_right")
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_pressed("jump") and coyote_timer > 0:
		handle_jump()

	if Input.is_action_just_pressed("dash") and not dash_used and speed <= move_speed:
		handle_dash()
		
	if Input.is_action_pressed("dive") and velocity.y > 0:
		handle_dive()

	if direction:
		velocity.x = direction * speed
		anim.play("run")
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
	anim.play("jump")
	velocity.y = jump_velocity
	coyote_timer = 0.0
	
	if is_diving and dive_jump_timer > 0 and abs(velocity.x) > 320:
		handle_dive_jump()


func handle_dash():
	anim.play("dash")
	dash_used = true
	speed += dash_speed
	await get_tree().create_timer(dash_time).timeout
	dash_used = false


func handle_dive():
	anim.play("dive")
	velocity.y = -jump_velocity
	is_diving = true
	dive_jump_timer = dive_jump_window


func handle_dive_jump():
	is_diving = false
	speed += dive_boost
	if speed > max_speed:
		speed = max_speed


func _physics_process(delta):
	if dive_jump_timer > 0:
		dive_jump_timer -= delta
