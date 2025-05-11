extends CharacterBody3D

@onready var head: Node3D = $head
@onready var collision: CollisionShape3D = $Collision
@onready var collisioncrouch: CollisionShape3D = $Collisioncrouch

var speed = 5.0
const walkspeed = 5.0
const crouchspeed = 3.0
const JUMP_VELOCITY = 4.5
const mouse_sens = 0.4
signal playerhit

var direction = Vector3.ZERO
var lerp_speed = 15
var pitch := 0.0
const PITCH_MIN = -60.0
const PITCH_MAX = 90.0
var crouchdepth = -0.5
var target_height = 1.7

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		# Rotação horizontal do corpo
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))

		# Rotação vertical da cabeça com valor absoluto
		pitch = clamp(pitch - event.relative.y * mouse_sens, PITCH_MIN, PITCH_MAX)
		head.rotation_degrees.x = pitch
	
	
	
func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("crouch"):
		speed = crouchspeed
		target_height = 1.7 + crouchdepth
		collisioncrouch.disabled = false
		collision.disabled = true
	else:
		speed = walkspeed
		target_height = 1.7
		collisioncrouch.disabled = true
		collision.disabled = false

	head.position.y = lerp(head.position.y, target_height, clamp(delta * lerp_speed, 0.0, 1.0))

		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * lerp_speed)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func hit():
	emit_signal("playerhit")
