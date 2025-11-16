extends CharacterBody2D

@export var v: float # Velocidade
@export var v_salto: float # Velocidade salto
@export var g: float # Gravedade
@export var tilemap: TileMapLayer # Mundo

var _mirando_dereita = true
var current_platform: Node = null
var subterraneo = false

func _physics_process(delta: float) -> void:
	mover_x()
	flipear()
	saltar(delta)
	escarvar()
	move_and_slide()


func mover_x():
	var eixo = Input.get_axis("esquerda", "dereita")
	velocity.x = eixo * v


func flipear():
	if (_mirando_dereita and velocity.x < 0) or (not _mirando_dereita and velocity.x > 0):
		scale.x *= -1
		_mirando_dereita = !_mirando_dereita
		
		
func saltar(delta):
	if (Input.is_action_just_pressed("arriba") and is_on_floor()):
		velocity.y = - v_salto
	if (not is_on_floor()):
		velocity.y += g * delta


func mover_grid(mov):
	
	var tile_pos := tilemap.local_to_map(tilemap.to_local(global_position))
		
	if tile_pos.y == 1:
			tilemap.set_cell(tile_pos, 0, Vector2i(0,0))
	if mov == "abaixo":
		global_position = tilemap.to_global(tilemap.map_to_local(tile_pos+Vector2i(0,1)))
		tilemap.set_cell(tile_pos + Vector2i(0,1), 0, Vector2i(1,0))
	elif mov == "dereita":
		global_position = tilemap.to_global(tilemap.map_to_local(tile_pos+Vector2i(1,0)))
		tilemap.set_cell(tile_pos + Vector2i(1,0), 0, Vector2i(1,0))
	elif mov == "esquerda":
		global_position = tilemap.to_global(tilemap.map_to_local(tile_pos+Vector2i(-1,0)))
		tilemap.set_cell(tile_pos + Vector2i(-1,0), 0, Vector2i(1,0))
	elif mov == "arriba":
		global_position = tilemap.to_global(tilemap.map_to_local(tile_pos+Vector2i(0,-1)))
		if tilemap.get_cell_tile_data(tile_pos+Vector2i(0,-1)) == null:
			subterraneo = false
			g = 1200
		else:
			tilemap.set_cell(tile_pos + Vector2i(0,-1), 0, Vector2i(1,0))

	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 1.0, 0.3)
	$Sprite2D.z_index = 1
	print("pabaixo {0}, tilePos: {1}".format([global_position, tile_pos]))

func check_tile(direction:Vector2i) -> bool:
	var tile_pos := tilemap.local_to_map(tilemap.to_local(global_position))
	return tilemap.get_cell_tile_data(tile_pos+direction) != null
	
func escarvar():
	
	if (Input.is_action_just_pressed("abaixo") and is_on_floor() and (not subterraneo)):
		
		if not check_tile(Vector2i.DOWN):
			subterraneo = false
			g = 1200
			global_position += Vector2.DOWN * 512
			return
			
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
		tween.tween_callback(mover_grid.bind("abaixo"))
		subterraneo = true
	elif (Input.is_action_just_pressed("abaixo") and subterraneo):
		
		if not check_tile(Vector2i.DOWN):
			subterraneo = false
			g = 1200
			global_position += Vector2.DOWN * 512
			return
			
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
		tween.tween_callback(mover_grid.bind("abaixo"))
	elif (Input.is_action_just_pressed("dereita") and subterraneo):
		
		if not check_tile(Vector2i.RIGHT):
			subterraneo = false
			g = 1200
			global_position += Vector2.RIGHT * 512
			return
			
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
		tween.tween_callback(mover_grid.bind("dereita"))
	elif (Input.is_action_just_pressed("esquerda") and subterraneo):
		
		if not check_tile(Vector2i.LEFT):
			subterraneo = false
			g = 1200
			global_position += Vector2.LEFT * 512
			return
			
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
		tween.tween_callback(mover_grid.bind("esquerda"))
	elif (Input.is_action_just_pressed("arriba") and subterraneo):
		
		if not check_tile(Vector2i.UP):
			subterraneo = false
			g = 1200
			global_position += Vector2.UP * 512
			return
			
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
		tween.tween_callback(mover_grid.bind("arriba"))
			
	if subterraneo:
		g = 0
