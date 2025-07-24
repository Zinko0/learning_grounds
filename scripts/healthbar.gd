extends Sprite3D

@export var max_hp : int

func _ready() -> void:
	$SubViewport/Panel/ProgressBar.max_value = max_hp
	$SubViewport/Panel/ProgressBar.value = max_hp
	
func take_damage(damage : int):
	$SubViewport/Panel/ProgressBar.value -= damage 
