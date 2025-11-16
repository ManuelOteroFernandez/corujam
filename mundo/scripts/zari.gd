extends CharacterBody2D

@export var v: float # Velocidade
@export var v_salto: float # Velocidade salto
@export var g: float # Gravedade
@export var tilemap: TileMapLayer # Mundo

@onready var _initial_g = g

var _mirando_dereita = true
var _is_moving = false
var current_platform: Node = null
var subterraneo = false
var is_active_double_jump = false
var can_break_hard = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("abaixo") and not subterraneo:
		check_start_subterraneo(Vector2.DOWN)

func _physics_process(delta: float) -> void:
	if not subterraneo:
		mover_x()
		flipear()
		
		if not is_on_floor():
			velocity.y += g * delta
			excavar_in_air()
			
		move_and_slide()
		
		if Input.is_action_pressed("abaixo"):
			check_start_subterraneo(Vector2.DOWN)
		
	else:
		escarvar()
		
		
func excavar_in_air():
	if Input.is_action_pressed("arriba"):
		check_start_subterraneo(Vector2.UP)

	
func check_start_subterraneo(direction: Vector2 = Vector2.ZERO):
	var direction_x = 0
	var direction_y = 0
	if direction == Vector2.ZERO:
		direction_x = 1 if velocity.x > 0 else -1 if velocity.x < 0 else 0
		direction_y = 1 if velocity.y > 0 else -1 if velocity.y < 0 else 0
	else:
		direction_x = direction.x
		direction_y = direction.y
	
	
	if direction_x != 0:
		var check_dir = Vector2i(direction_x,0)
		if check_escavable(check_dir):
			go_in_subterraneo(check_dir)
	elif direction_y != 0:
		var check_dir = Vector2i(0,direction_y)
		if check_escavable(check_dir):
			go_in_subterraneo(check_dir)

func check_escavable(direction: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + 200 * direction
	)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result and result["collider"] and result["collider"].is_in_group("escavable"):
		return can_break_terrain(direction)
	
	return false



func mover_x():
	if not is_on_floor():
		return
		
	var eixo = Input.get_axis("esquerda", "dereita")
	velocity.x = eixo * v
	
	if eixo != 0:
		check_start_subterraneo(Vector2(eixo,0))


func flipear():
	if (_mirando_dereita and velocity.x < 0) or (not _mirando_dereita and velocity.x > 0):
		scale.x *= -1
		_mirando_dereita = !_mirando_dereita
		
		
func saltar():
	velocity.y = -v_salto * 3 if is_active_double_jump else -v_salto


func mover_grid(mov: Vector2i, close_hole = true):
	var tile_pos := tilemap.local_to_map(tilemap.to_local(global_position))

	global_position = tilemap.to_global(tilemap.map_to_local(tile_pos + mov))
	tilemap.set_cell(tile_pos + mov, 0, Vector2i(1,0))

	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 1.0, 0.3)
		
	await tween.finished
	_is_moving = false
	if close_hole:
		tilemap.set_cell(tile_pos, 0, Vector2i(4,0))

func check_tile(direction:Vector2i) -> bool:
	var tile_pos := tilemap.local_to_map(tilemap.to_local(global_position))
	return tilemap.get_cell_tile_data(tile_pos+direction) != null
	
func escarvar():
	
	if (Input.is_action_just_pressed("abaixo") and not _is_moving):
		
		if not check_tile(Vector2i.DOWN):
			if subterraneo:
				out_floor(Vector2.DOWN)
			return
		
		if not can_break_terrain(Vector2.DOWN): # Falla al escavar
			return
		
		_is_moving = true
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
		
		tween.tween_callback(mover_grid.bind(Vector2i.DOWN))
	elif (Input.is_action_just_pressed("dereita") and not _is_moving):
		
		if not check_tile(Vector2i.RIGHT):
			if subterraneo:			
				out_floor(Vector2.RIGHT)
			return
		
		if not can_break_terrain(Vector2.RIGHT): # Falla al escavar
			return
			
		_is_moving = true
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
		tween.tween_callback(mover_grid.bind(Vector2i.RIGHT))
	elif (Input.is_action_just_pressed("esquerda") and not _is_moving):
		
		if not check_tile(Vector2i.LEFT):
			if subterraneo:
				out_floor(Vector2.LEFT)
			return
		
		if not can_break_terrain(Vector2.LEFT): # Falla al escavar
			return
		
		_is_moving = true
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
		tween.tween_callback(mover_grid.bind(Vector2i.LEFT))
	elif (Input.is_action_just_pressed("arriba") and not _is_moving):
		
		if not check_tile(Vector2i.UP):
			if subterraneo:
				out_floor(Vector2.UP)
			return
		
		if not can_break_terrain(Vector2.UP): # Falla al escavar
			return
		
		_is_moving = true
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
		tween.tween_callback(mover_grid.bind(Vector2i.UP))
			
	if subterraneo:
		g = 0

func out_floor(direction:Vector2):
	var tile_pos := tilemap.local_to_map(tilemap.to_local(global_position))
	
	subterraneo = false
	g = _initial_g
	global_position += direction * 512
	
	velocity = Vector2.ZERO
	
	move_and_slide()
	
	if direction == Vector2.UP:
		saltar()
	
	tilemap.set_cell(tile_pos, 0, Vector2i(4,0))
	
func go_in_subterraneo(direction: Vector2i):
	if _is_moving:
		return
	
	_is_moving = true
		
		
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
	tween.tween_callback(mover_grid.bind(direction, false))
	
	subterraneo = true

func can_break_terrain(direction: Vector2) -> bool:
	var tile_pos := tilemap.local_to_map(tilemap.to_local(global_position + 512 * direction))
	var datos = tilemap.get_cell_tile_data(tile_pos)
	if datos and datos.get_custom_data("is_hard") and not can_break_hard:
		return false
	return true
