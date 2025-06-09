extends CharacterBody3D

var time_since_last_attack = 0.0
var player = null
const speed = 2.5
const ATKrange = 200
const ATKcooldown = 0.75
@export var playerpath := "/root/Main/world/NavigationRegion3D/player"
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")
var hp = 150
var is_attacking = false
@onready var navagent = $NavigationAgent3D
signal playerhit

@onready var ATKtimer: Timer = $ATKtimer
@onready var muzzle = $muzzle
@export var bullet_scene: PackedScene = preload("res://enemy_bullet.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(playerpath)
signal DEAD



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global_transform.origin.distance_to(player.global_transform.origin) > 1.0:
		navagent.target_position = player.global_transform.origin

	# Pega o próximo ponto da navegação
	var next_nav_point = navagent.get_next_path_position()
	var direction = (next_nav_point - global_transform.origin).normalized()

	velocity = direction * speed
	move_and_slide()

	# Olha para o jogador (mantendo a rotação só no eixo Y)
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if target_in_range():
			if not is_attacking:
				is_attacking = true
				ATKtimer.start()
	else:
		is_attacking = false
		ATKtimer.stop()

func target_in_range():
	return global_position.distance_to(player.global_position) < ATKrange
	
func hit():
	emit_signal("playerhit")

func _on_area_3d_head_headhit(dam):
	hp -= dam
	if hp <= 0:	
		emit_signal("DEAD")
		queue_free()

func _on_area_3d_torsohit(dam):
	hp -= dam
	if hp <= 0:
		emit_signal("DEAD")
		queue_free()
		

func _on_ATKtimer_timeout() -> void:
	if target_in_range():
		shoot_projectile()
	else:
		is_attacking = false
		ATKtimer.stop()


func shoot_projectile():
	var bullet = bullet_scene.instantiate()
	var to_player = (player.global_position + Vector3(0, 1.5, 0) - muzzle.global_position).normalized()

	bullet.position = muzzle.global_position
	bullet.direction = to_player

	get_tree().current_scene.add_child(bullet)
	bullet.look_at(player.global_position + Vector3(0, 1.5, 0), Vector3.UP)
