extends Node2D

@export var tipinho1: Node2D
@export var tipinho2: Node2D
@export var tipinho3: Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.is_active_double_jump = true
		
		tipinho1.visible = true;
		tipinho2.visible = false;
		tipinho3.visible = false;
		
		queue_free()
