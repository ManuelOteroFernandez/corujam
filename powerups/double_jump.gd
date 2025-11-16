extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.is_in_group("player"):
		body.is_active_double_jump = true
		
		queue_free()
