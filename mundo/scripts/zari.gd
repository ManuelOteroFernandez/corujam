extends CharacterBody2D

@export var v: float # Velocidade
@export var v_salto: float # Velocidade salto
@export var g: float # Gravedade

var _mirando_dereita = true

func _physics_process(delta: float) -> void:
	mover_x()
	flipear()
	saltar(delta)	
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
