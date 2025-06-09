extends Control
@onready var hit_rectangle: ColorRect = $hit_rectangle
@onready var healthbar: ProgressBar = $healthbar
@onready var kill_label: Label = $KillLabel

var kill_count := 0
var ammo_count := 20


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	

func set_health(value: int, max_value: int):
	healthbar.max_value = max_value
	healthbar.value = value
	
func _on_player_playerhit() -> void:
	hit_rectangle.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rectangle.visible = false


func _on_enemy_dead() -> void:
	kill_count += 1
	$KillLabel.text = "SCORE: %d" % kill_count

func _on_player_shot():
	ammo_count -= 1
	$ammo.text = "%d/20" %ammo_count
	

func _on_player_reloading() -> void:
	ammo_count = 20
	$ammo.text = "%d/20" %ammo_count
	
func update_label(active: bool) -> void:
	$Sensor.text = "sensor: 11111111" if active else "sensor: 00000000"
