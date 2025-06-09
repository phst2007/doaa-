extends Node3D

@export var range: float = 50.0
@export var fire_rate: float = 2
@export var bullet_scene: PackedScene = load("res://bullet.tscn")
@onready var muzzle: Node3D = $headnode/barrels/muzzle
@onready var atk_timer: Timer = $ATKcooldown
@onready var head: Node3D = $headnode


var is_attacking = false
var target: Node3D = null

func _ready():
	atk_timer.wait_time = fire_rate
	atk_timer.timeout.connect(shoot_projectile)

func _process(delta):
	find_target()

	if target and is_instance_valid(target):
		var target_pos = target.global_position
		var to_target = (target_pos - global_position).normalized()

		# Rotação suave apenas no eixo Y
		var current_rotation = rotation.y
		var desired_rotation = atan2(to_target.x, to_target.z)
		rotation.y = lerp_angle(current_rotation, desired_rotation, delta * 5.0)

		# Controle de ataque
		if global_position.distance_to(target.global_position) <= range:
			if not is_attacking:
				is_attacking = true
				atk_timer.start()
		else:
			is_attacking = false
			atk_timer.stop()
	else:
		is_attacking = false
		atk_timer.stop()


func find_target():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_dist = INF
	target = null

	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest_dist = dist
			target = enemy

func shoot_projectile():
	if not target:
		return
	
	var bullet = bullet_scene.instantiate()
	var to_target = (target.global_position + Vector3(0, 1.5, 0) - muzzle.global_position).normalized()
	
	bullet.global_position = muzzle.global_position
	if bullet.has_method("set_direction"):
		bullet.set_direction(to_target)
	
	get_tree().current_scene.add_child(bullet)
	bullet.look_at(target.global_position + Vector3(0, 1.5, 0), Vector3.UP)
