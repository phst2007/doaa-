extends Node3D

const SPEED = 50.0

@onready var mesh: MeshInstance3D = $Mesh
@onready var bullet_raycast: RayCast3D = $bullet_raycast
var direction = Vector3.ZERO
var has_collided = false

func _physics_process(delta: float) -> void:
	if has_collided:
		return

	position += -transform.basis.z * SPEED * delta

	if bullet_raycast.is_colliding():
		has_collided = true
		mesh.visible = false
		bullet_raycast.enabled = false

		var collider = bullet_raycast.get_collider()
		if collider and collider.is_in_group("player") and collider.has_method("hit"):
			collider.hit()

		# Espera e remove o projétil mesmo se não for o jogador
		await get_tree().create_timer(1.0).timeout
		queue_free()
