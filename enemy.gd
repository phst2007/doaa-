extends CharacterBody3D

var time_since_last_attack = 0.0
var player = null
const speed = 2.5
const ATKrange = 5
const ATKcooldown = 1.5
@export var playerpath : NodePath
@onready var navagent = $NavigationAgent3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node(playerpath)


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
	
	var distance = global_position.distance_to(player.global_position)

	# Atualiza temporizador
	time_since_last_attack += delta

	# Se está no alcance, para e ataca
	if distance < ATKrange:
		velocity = Vector3.ZERO
		if time_since_last_attack >= ATKcooldown:
			player.hit()
			time_since_last_attack = 0.0
	
func target_in_range() -> bool:
	return global_position.distance_to(player.global_position) < ATKrange
	
func try_attack():
	if global_position.distance_to(player.global_position) < ATKrange:
		player.hit()
		

	
