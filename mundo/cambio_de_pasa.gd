extends Area2D

@export var pasa01: Node
@export var pasa02: Node



func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	if pasa01:
		pasa01.visible = false
		
	if pasa02:
		pasa02.visible = true
