extends Control

@export var menu_area :HFlowContainer
var moleculas := {}

func _ready() -> void:
	monta_view()
	
func ler_banco() -> void:
	moleculas = MoleculasDb.molecula
	
func monta_view() -> void:
	ler_banco()
	for x in moleculas:
		monta_item_view(moleculas[x].id)

func monta_item_view(index:int) -> void:
	var control = Control.new()
	control.custom_minimum_size = Vector2(300,300)
	var subviewConteiner = SubViewportContainer.new()
	subviewConteiner.stretch = true
	subviewConteiner.size = Vector2(300,300)
	var subview = SubViewport.new()
	var scena = preload("res://cenas/molecula_render.tscn")
	var inst = scena.instantiate()
	inst.molecula_alvo = index
	subview.add_child(inst)
	subviewConteiner.add_child(subview)
	control.add_child(subviewConteiner)
	menu_area.add_child(control)
	


func _on_fechar_button_up() -> void:
	self.queue_free()
