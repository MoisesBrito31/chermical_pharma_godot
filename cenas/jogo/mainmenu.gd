extends Node2D

@onready var pan_load: PanelContainer = $Control/pan_load
@onready var list_save: ItemList = $Control/pan_load/VBoxContainer/list_save
@onready var but_loadFile: Button = $Control/pan_load/VBoxContainer/HBoxContainer/but_loadFile
@onready var but_erase: Button = $Control/pan_load/VBoxContainer/HBoxContainer/but_erase
@onready var but_newGame: Button = $Control/but_ng
@onready var pan_new: PanelContainer=$Control/pan_new
@onready var input_name: TextEdit = $Control/pan_new/VBoxContainer/input_file_name
@onready var but_criar: Button = $Control/pan_new/VBoxContainer/HBoxContainer/MarginContainer2/but_criar

var target_file: String = ""
var target_file_index: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_but_exit_button_up() -> void:
	get_tree().quit()


func _on_but_load_button_up() -> void:
	if DirAccess.dir_exists_absolute("res://saves") == false:
		DirAccess.make_dir_absolute("res://saves")
	$Control/pan_load.visible = true
	var dir := DirAccess.open("res://saves")

	if dir:
		list_save.clear()
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if file_name.get_extension().to_lower() == "save":
				var index = list_save.add_item(file_name)
				list_save.set_item_metadata(index,{"name":file_name})
			file_name = dir.get_next()
			
	dir.list_dir_end()


func _on_but_cancel_button_up() -> void:
	target_file=""
	target_file_index = -1
	but_erase.disabled = true
	but_loadFile.disabled = true
	pan_load.visible = false


func _on_list_save_item_selected(index: int) -> void:
	but_erase.disabled = false
	but_loadFile.disabled = false
	var nome = list_save.get_item_metadata(index)
	target_file = nome.name
	target_file_index = index


func _on_but_erase_button_up() -> void:
	var dir = DirAccess.open("res://saves")
	if dir.file_exists(target_file) == true:
		dir.remove(target_file)
	list_save.remove_item(target_file_index)
	target_file=""
	target_file_index = -1
	but_erase.disabled = true
	but_loadFile.disabled = true
	
	


func _on_but_new_cancel_button_up() -> void:
	pan_new.visible = false
	but_criar.disabled = true
	input_name.text = ""


func _on_but_ng_button_up() -> void:
	pan_new.visible = true
	but_criar.disabled = true
	input_name.text = ""


func _on_input_file_name_text_changed() -> void:
	if len(input_name.text)>0:
		but_criar.disabled=false
	else:
		but_criar.disabled=true


func _on_but_criar_button_up() -> void:
	var dir = DirAccess.open("res://saves")
	if dir.file_exists("%s.save"%[input_name.text]) == false:
		var file = FileAccess.open("res://saves/%s.save"%[input_name.text],FileAccess.WRITE)
		var data:={
			"name":input_name.text,
			"criation":Time.get_datetime_dict_from_system(),
			"moleculas":{}
		}
		file.store_string(JSON.stringify(data))
		file.close()
	pan_new.visible = false
	but_criar.disabled = true
	input_name.text = ""


func _on_but_load_file_button_up() -> void:
	if FileAccess.file_exists("res://saves/%s"%[target_file]):
		var file = FileAccess.open("res://saves/%s"%[target_file],FileAccess.READ)
		var context = file.get_as_text()
		var result = JSON.parse_string(context)
		var scena = preload("res://cenas/jogo/menu_player.tscn")
		var inst = scena.instantiate()
		inst.init(result)
		get_tree().root.add_child(inst)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = inst
	else:
		pass
		

func normalizar_numeros(value):
	match typeof(value):

		TYPE_FLOAT:
			# se não há parte decimal, converte para int
			if value == int(value):
				return int(value)
			return value

		TYPE_ARRAY:
			for i in value.size():
				value[i] = normalizar_numeros(value[i])
			return value

		TYPE_DICTIONARY:
			for k in value.keys():
				value[k] = normalizar_numeros(value[k])
			return value

		_:
			return value
