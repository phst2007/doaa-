extends Area3D
@export var damage := 50
signal torsohit(dam)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func hit():
	emit_signal("torsohit", damage)
