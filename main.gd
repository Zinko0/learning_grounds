extends Node3D


func _ready() -> void:
	$Control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	randomize()
