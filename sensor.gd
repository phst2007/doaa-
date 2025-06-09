extends Node3D

@onready var raycast: RayCast3D = $raycast

signal detected_state_changed(active: bool)

var detected = false

func _process(delta):
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider != null and collider.is_in_group("enemies"):
			if not detected:
				detected = true
				emit_signal("detected_state_changed", true)
			return
	if detected:
		detected = false
		emit_signal("detected_state_changed", false)
