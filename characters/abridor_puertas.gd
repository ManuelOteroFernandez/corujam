extends Node2D
@export var porta1: StaticBody2D

func show_key():
	var tween = get_tree().create_tween()
	tween.tween_property($Key,"modulate:a",1,0.5)
	
	
func hide_key():
	var tween = get_tree().create_tween()
	tween.tween_property($Key,"modulate:a",0,0.5)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	show_key()
	body.interact_signal.connect(action)
	body.can_interact = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	hide_key()
	$CanvasLayer/DialogUi.hide_dialog()
	if body.interact_signal.is_connected(action):
		body.interact_signal.disconnect(action)
	body.can_interact = false

func action():
	$CanvasLayer/DialogUi.start_dialog()
	porta1.queue_free()
	
