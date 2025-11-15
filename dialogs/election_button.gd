class_name ElectionButton
extends Button

signal next_line_signal(next_line_id: int)

var next_line_id: int = -1

func set_up(text_in:String, next_line_id_in: int):
	text = text_in
	next_line_id = next_line_id_in

func _on_pressed() -> void:
	next_line_signal.emit(next_line_id)
