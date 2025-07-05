extends Node2D

const SPEED = 60

var dir = 1
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta: float) -> void:
	#delta é o tempo que se passou desde o ultimo frame
	#como os FPS mudam ao longo do tempo nao dá para dizer para mexer X em cada frame
	#usa-se o delta para o garantir movimento consistente
	#60 pixeis per second
	if ray_cast_right.is_colliding():
		animated_sprite.flip_h = true
		dir = -1
	if ray_cast_left.is_colliding():
		animated_sprite.flip_h = false
		dir = 1
		
	position.x += dir * SPEED * delta
