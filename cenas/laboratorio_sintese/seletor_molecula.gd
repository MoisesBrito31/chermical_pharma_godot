extends Control

@export var options_but: OptionButton
@export var vbox: VBoxContainer
@export var view: SubViewport

signal selected

var moleculas := []

func _ready() -> void:
	carrega_lista()

func carrega_lista() -> void:
	moleculas = MoleculasDb.obter_todas_moleculas_do_banco()
	var index = 0
	for mo in moleculas:
		options_but.add_item(str(mo.id))
		options_but.set_item_metadata(index,{"id":mo.id})
		index+=1
		


func _on_option_button_item_selected(index: int) -> void:
	for c in view.get_children():
		print(c.name)
		if c.name.substr(0,15) == "molecula_render":
			c.queue_free()
	var moRe = preload("res://cenas/molecula_render.tscn")
	var inst = moRe.instantiate()
	var meta = options_but.get_item_metadata(index)
	inst.molecula_alvo = meta.get("id")
	inst.name = "molecula_render_%d"%[ meta.get("id")]
	view.add_child(inst)
	emit_signal("selected",meta)
	
	
