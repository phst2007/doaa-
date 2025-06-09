extends Node3D
@onready var player: CharacterBody3D = $world/NavigationRegion3D/player
@onready var navigation_region_3d: NavigationRegion3D = $world/NavigationRegion3D
@onready var hud: Control = $HUD
@onready var spawns: Node3D = $world/spawns

var enemy = load("res://enemy.tscn")


var instance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _ready():
	randomize()
	

	
func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)



func _on_timerenemyspawner_timeout():
	var enemy_spawnpoint = _get_random_child(spawns).global_position
	instance = enemy.instantiate()
	instance.position = enemy_spawnpoint
	navigation_region_3d.add_child(instance)
	instance.add_to_group("enemies")
	instance.connect("DEAD", Callable(hud, "_on_enemy_dead"))
