extends Control

@onready var level = preload("res://mundo/Level.tscn")

var is_changing_scene = false

func change_scene(next_scene:PackedScene):
	is_changing_scene = true
	var tween = get_tree().create_tween()
	tween.tween_property(self,"modulate:a", 0, 1)
	await tween.finished
	get_tree().change_scene_to_packed(next_scene)
	
	


func _on_btn_start_pressed() -> void:
	if not is_changing_scene:
		change_scene(level)
