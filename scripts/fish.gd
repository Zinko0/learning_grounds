extends StaticBody3D



@export var attack_duration: float = 0.3
@export var attack_cooldown: float = 0.5
@export var attack_hitbox: Area3D
@export var attack_audio: AudioStreamPlayer3D
@export var animator: AnimationPlayer
@export var attack_animation_name: String = "attack"

var is_attacking: bool = false
var attack_timer: float = 0.0
var cooldown_timer: float = 0.0

func _process(delta: float) -> void:
	if Input.is_action_pressed("attack"):
		try_attack()
		
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0.0:
			end_attack()
	else:
		cooldown_timer = max(0.0, cooldown_timer - delta)

func try_attack():
	if is_attacking or cooldown_timer > 0.0:
		return

	is_attacking = true
	attack_timer = attack_duration
	cooldown_timer = attack_cooldown

	if animator and attack_animation_name != "":
		animator.play(attack_animation_name)
	if attack_audio:
		attack_audio.play()
	if attack_hitbox:
		attack_hitbox.monitoring = true
		attack_hitbox.visible = true  # Debug

func end_attack():
	is_attacking = false
	if attack_hitbox:
		attack_hitbox.monitoring = false
		attack_hitbox.visible = false  # Debug


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(2, Vector3.ZERO)
