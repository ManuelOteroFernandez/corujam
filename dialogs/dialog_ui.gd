extends Control

@export var character_img_left: Texture2D
@export var character_img_right: Texture2D
@export var dialog_line_array: Array[DialogLine]

@onready var ElectionButtonTscn: PackedScene = load("res://dialogs/election_button.tscn")
@onready var electionContainer = $Panel/MarginContainer/VBoxContainer/HBoxContainer

var current_line: DialogLine
var next_line: DialogLine

func start_dialog():
	var tween = get_tree().create_tween()
	scale = Vector2(1,1)
	tween.tween_property(self,"modulate:a",1, 1)
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CharacterLeft.texture = character_img_left
	$CharacterRight.texture = character_img_right
	
	show_next_line()
	
func show_next_line():
	if current_line == null:
		current_line = dialog_line_array[0]
		next_line = get_line(current_line.next_line_id)
	
	if next_line == null:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0, 1)
		await tween.finished
		queue_free()
		size = Vector2.ZERO
		return
	
	current_line = next_line
	$Panel/MarginContainer/VBoxContainer/Text.text = current_line.text
	
	if current_line.elections.is_empty():
		next_line = get_line(current_line.next_line_id)
		$Button.visible = true
		
	else:
		show_elections()
		next_line = null
		$Button.visible =  false

func show_elections():
	for dialog_election in current_line.elections:
		var new_button: ElectionButton = ElectionButtonTscn.instantiate()
		new_button.set_up(dialog_election.text, dialog_election.next_line_id)
		electionContainer.add_child(new_button)
		new_button.next_line_signal.connect(on_button_next_line)
	
func on_button_next_line(line_id: int):
	next_line = get_line(line_id)
	remove_elections()
	show_next_line()
	
func remove_elections():
	for child in electionContainer.get_children():
		child.queue_free()
	
func get_line(line_id:int):
	for line in dialog_line_array:
		if line.id == line_id:
			return line

	return null


func _on_button_pressed() -> void:
	show_next_line()
