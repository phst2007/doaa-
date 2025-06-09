extends Node3D

const SPEED = 75.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var bullet_raycast: RayCast3D = $bullet_raycast

var has_collided = false

func _physics_process(delta: float) -> void:
	if has_collided:
		return

	position += transform.basis * Vector3(0, 0, -SPEED) * delta

	if bullet_raycast.is_colliding():
		has_collided = true
		mesh.visible = false
		bullet_raycast.enabled = false

		var collider = bullet_raycast.get_collider()
		if collider and collider.is_in_group("enemy"):
			if collider.has_method("hit"):
				collider.hit()

		await get_tree().create_timer(1.0).timeout
		queue_free()
