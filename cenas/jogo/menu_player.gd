extends Control

@onready var name_player: RichTextLabel = $txt_player_name
var dados = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name_player.text = dados.name
	MoleculasDb.carrega_banco(dados)


func init(context:Dictionary) -> void:
	dados = context
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_but_sair_button_up() -> void:
	get_tree().change_scene_to_file("res://cenas/jogo/mainmenu.tscn")


func _on_but_biblioteca_button_up() -> void:
	var bibli = preload("res://cenas/jogo/biblioteca_moleculas.tscn")
	var inst = bibli.instantiate()
	get_tree().root.add_child(inst)


func _on_but_panejador_pressed() -> void:
	var bibli = preload("res://cenas/jogo/planejador_particula.tscn")
	var inst = bibli.instantiate()
	get_tree().root.add_child(inst)


func _on_but_salvar_button_up() -> void:
	var dir = DirAccess.open("res://saves")
	if dir.file_exists("%s.save"%[dados.name]) == true:
		dir.remove("%s.save"%[dados.name])
		var file = FileAccess.open("res://saves/%s.save"%[dados.name],FileAccess.WRITE)
		var data:={
			"name":dados.name,
			"criation":Time.get_datetime_dict_from_system(),
			"moleculas":MoleculasDb.molecula
		}
		file.store_string(JSON.stringify(data))
		file.close()


func _on_but_lab_sintese_button_up() -> void:
	var bibli = preload("res://cenas/jogo/laboratorio_sintese.tscn")
	var inst = bibli.instantiate()
	get_tree().root.add_child(inst)
