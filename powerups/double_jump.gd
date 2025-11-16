extends Node2D
@onready var sound = $"../itemConseguido"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.is_active_double_jump = true
		sound.play()
		
		queue_free()
