extends Node3D
@onready var hit_rectangle: ColorRect = $ui/hit_rectangle
@onready var player: CharacterBody3D = $world/NavigationRegion3D/playermain


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _ready():
	pass
	
func _on_playermain_playerhit():
	hit_rectangle.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rectangle.visible = false
