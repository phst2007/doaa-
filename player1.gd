extends CharacterBody3D


#camera
@onready var head: Node3D = $head
const PITCH_MIN = -60.0
const PITCH_MAX = 90.0
const mouse_sens = 0.1
#fisica
@onready var collision: CollisionShape3D = $standingcolision
@onready var collisioncrouch: CollisionShape3D = $crouchingcolision
@onready var tophat: Node3D = $tophat
var speed = 5.0
const walkspeed = 5.0
const crouchspeed = 3.0
const JUMP_VELOCITY = 4.5
var crouchdepth = -0.5
var target_height = 1.7

#arma
@onready var gun_anim: AnimationPlayer = $head/gun_holder/ak47/gun_AnimationPlayer
@onready var gun_barrel: = $head/muzzle
var max_ammo = 20
var current_ammo = max_ammo
var is_reloading = false
signal shot
signal reloading

var bullet = load("res://bullet.tscn")
var bullet_instance




#dano
signal playerhit
var max_hp = 100
var hp = max_hp
@onready var damage_timer: Timer = $timers/DamageTimer
@onready var heal_timer: Timer = $timers/HealTimer

#ETC
var direction = Vector3.ZERO
var lerp_speed = 15
var pitch := 0.0
@onready var hud: Control = $"../../../HUD"


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
		target_height = 2.0 + crouchdepth
		collisioncrouch.disabled = false
		collision.disabled = true
		tophat.visible = false
		
	else:
		speed = walkspeed
		target_height = 2.0
	
		collisioncrouch.disabled = true
		collision.disabled = false
		tophat.visible = true

	head.position.y = lerp(head.position.y, target_height, clamp(delta * lerp_speed, 0.0, 1.0))

		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
			velocity.y = 0  # evita acúmulo ao tocar o chão
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

	if Input.is_action_just_pressed("reload") and !is_reloading:
		reload()

	if Input.is_action_pressed("shoot") and !is_reloading:
		if current_ammo > 0:
			if !gun_anim.is_playing():
				shoot()
	sentry()
	sensor()

func hit():
	emit_signal("playerhit")
	hp -= 10 
	hp = clamp(hp, 0, max_hp)
	damage_timer.start()
	heal_timer.stop()
	
	hud.set_health(hp, max_hp)
	if hp <= 0:
		die()
		
		
func die():
	get_tree().reload_current_scene()  



func _on_damage_timer_timeout() -> void:
	if hp < max_hp:
		heal_timer.start()

func _on_heal_timer_timeout() -> void:
	if hp < max_hp:
		hp += 5
		hp = clamp(hp, 0, max_hp)
		hud.set_health(hp, max_hp)
	else:
		heal_timer.stop()
		
		var kill_count := 0

func shoot():
	gun_anim.play("shoot")
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = gun_barrel.global_position
	bullet_instance.transform.basis = gun_barrel.global_transform.basis
	get_parent().add_child(bullet_instance)

	current_ammo -= 1
	emit_signal("shot") 

func reload():
	is_reloading = true
	await get_tree().create_timer(1.5).timeout  # tempo de recarga
	current_ammo = max_ammo
	is_reloading = false
	emit_signal("reloading")
	
func sentry():
	if Input.is_action_just_pressed("skill1"):
		# Verifica se já existe uma torreta na cena
		var turrets = get_tree().get_nodes_in_group("turrets")
		if turrets.size() > 0:
			# Se já houver uma torreta, remove a antiga
			var old_turret = turrets[0]
			if is_instance_valid(old_turret):
				old_turret.queue_free()

		# Instancia a nova torreta
		var turret_scene: PackedScene = preload("res://turret.tscn")
		var turret_instance = turret_scene.instantiate()

		# Adiciona ao grupo "turrets" para futura verificação
		turret_instance.add_to_group("turrets")

		# Calcula posição 2 metros à frente do jogador
		var forward_dir = -global_transform.basis.z.normalized()
		var spawn_position = global_transform.origin + forward_dir * 2.0

		# Define a rotação olhando na mesma direção do jogador
		var spawn_transform = Transform3D(global_transform.basis, spawn_position)
		turret_instance.global_transform = spawn_transform

		# Adiciona a nova torreta à cena
		get_tree().current_scene.add_child(turret_instance)
		
func sensor():
	if Input.is_action_just_pressed("skill2"):
		var SENSOR = preload("res://sensor.tscn")
		var sensor_instance = SENSOR.instantiate()

		var forward = -global_transform.basis.z.normalized()
		var spawn_pos = global_transform.origin + forward * 1.0 + Vector3.UP

		# Ajusta a posição e rotação ao mesmo tempo
		var new_transform = Transform3D(global_transform.basis, spawn_pos)
		sensor_instance.global_transform = new_transform

		# Adiciona o sensor na cena do mapa (root da cena principal)
		var map_scene = get_tree().current_scene
		map_scene.add_child(sensor_instance)
		sensor_instance.add_to_group("sensors")

		# Conecta o signal para o mapa (root da cena atual)
		sensor_instance.connect("detected_state_changed", Callable(self, "_on_sensor_detected_changed"))

		var sensors = get_tree().get_nodes_in_group("sensors")
		if sensors.size() > 2:
			var old = sensors[0]
			if is_instance_valid(old):
				old.queue_free()
				
func _on_sensor_detected_changed(active: bool) -> void:
	hud.update_label(active)
	print("Sensor active?", active)
