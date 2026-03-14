extends Node2D

@export var sprite:Sprite2D
@export var sinal:Label
@export var colide: CollisionShape2D
@export var pan_option: PanelContainer

signal conectar
signal deletar
signal drag
signal drop
signal drop_valid

var img_circulo = load("res://assets/formas/circulo.png")
var img_quadrado = load("res://assets/formas/quadrado.png")
var img_pentagono  = load("res://assets/formas/pentagono.png")
var img_triangulo  = load("res://assets/formas/triangulo.png")

var id = 0
var particula = 2
var carga = 1
var base_position = Vector2(0,0)
var alvo_position = Vector2(0,0)
var clicou = false
var over = false
var dragging = false
var droped = false
var areaOcupada = false

func _ready() -> void:
	match particula:
		MoleculasDb.tipo.CIRCULO:
			sprite.texture = img_circulo
		MoleculasDb.tipo.QUADRADO:
			sprite.texture = img_quadrado
		MoleculasDb.tipo.TRIANGULO:
			sprite.texture = img_triangulo
		MoleculasDb.tipo.PENTAGONO:
			sprite.texture = img_pentagono
	match carga:
		MoleculasDb.sinal.P:
			sprite.self_modulate = Color(0,0,1,1)
			sinal.text = "+"
		MoleculasDb.sinal.N:
			sprite.self_modulate = Color(1,0,0,1)
			sinal.text = "-"
	base_position = position
	alvo_position = position
	
func _process(delta: float) -> void:
	if over and Input.is_action_just_pressed("mouse_right"):
		pan_option.visible = true
	if over and Input.is_action_just_pressed("mouse_left"):
		dragging = true
		emit_signal("drag")
	if dragging and Input.is_action_just_released("mouse_left"):
		dragging = false
		droped = true
		emit_signal("drop")
	if dragging:
		position = get_global_mouse_position()
	if droped:
		if alvo_position == base_position:
			position = base_position
		else:
			position = alvo_position
			base_position = alvo_position
			emit_signal("drop_valid")
		droped = false
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name.substr(0,15) == "drag_drop_pivot" and areaOcupada == false:
		alvo_position = area.position


func _on_area_2d_area_exited(area: Area2D) -> void:	
	if area.name.substr(0,15) == "drag_drop_pivot":
		alvo_position = base_position


func _on_mouse_area_mouse_entered() -> void:
	over = true
	sprite.modulate = Color(1,1,1,0.2)


func _on_mouse_area_mouse_exited() -> void:
	over = false
	sprite.modulate = Color(1,1,1,1)


func _on_mouse_area_area_entered(area: Area2D) -> void:
	if area.name.substr(0,13) == "par_mouseArea":
		areaOcupada = true
		alvo_position = base_position


func _on_mouse_area_area_exited(area: Area2D) -> void:
	if area.name.substr(0,13) == "par_mouseArea":
		alvo_position = base_position
		areaOcupada = false


func _on_but_cancelar_button_up() -> void:
	pan_option.visible = false


func _on_but_apagar_button_up() -> void:
	var context = {
		"id": id,
		"particula": particula,
		"carga": carga,
		"x_y":base_position
	}
	emit_signal("deletar",context)
	queue_free()


func _on_but_conectar_button_up() -> void:
	var context = {
		"id": id,
		"particula": particula,
		"carga": carga,
		"x_y":base_position
	}
	pan_option.visible=false
	emit_signal("conectar",context)
