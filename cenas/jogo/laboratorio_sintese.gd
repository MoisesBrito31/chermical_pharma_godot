extends Control

@export var but_sintese: Button
@export var resultView: SubViewport
@export var pan_alert: PanelContainer
@export var txt_alert: Label
@export var but_salvar: Button

var mo1 :={}
var mo2 :={}
var mo1_ok = false
var mo2_ok = false
var mo_gerada :={}


func _on_but_fechar_button_up() -> void:
	queue_free()


func _on_seletor_molecula_selected(context:Dictionary) -> void:
	print("seletor 1: ")
	print(context)
	mo1 = MoleculasDb.obter_dados(context.id).duplicate(true)
	mo1_ok = true
	if pode_sintetizar():but_sintese.disabled = false


func _on_seletor_molecula_2_selected(context:Dictionary) -> void:
	print("seletor 2:")
	print(context)
	mo2 = MoleculasDb.obter_dados(context.id).duplicate(true)
	mo2_ok = true
	if pode_sintetizar():but_sintese.disabled = false


func _on_but_sintase_button_up() -> void:
	"""print("particulas:")
	print(mo1.particulas)
	print("ligacoes:")
	print(mo1.ligacoes)
	print("--------")
	print("particulas:")
	print(mo2.particulas)
	print("ligacoes:")
	print(mo2.ligacoes)"""
	mo_gerada = MoleculaRules.sintese(mo1.duplicate(true),mo2.duplicate(true))
	"""print("--------")
	print("particulas:")
	print(mo_gerada.particulas)
	print("ligacoes:")
	print(mo_gerada.ligacoes)"""
	but_sintese.disabled = true
	for c in resultView.get_children():
		print(c.name)
		c.queue_free()
	if mo_gerada == {}:
		txt_alert.text="Resultado invalido, não há sintese válida para as moleculas usadas"
		pan_alert.visible= true
		return
	var banco = MoleculasDb.obter_todas_moleculas_do_banco()
	for item in banco:
		if MoleculaRules.molecula_is_equal(item,mo_gerada) == true:
			txt_alert.text = "Molecula Já Descoberta"
			pan_alert.visible = true
			but_salvar.disabled = true
			break
		else:
			but_salvar.disabled = false
	var moRe = preload("res://cenas/molecula_render.tscn")
	var inst = moRe.instantiate()
	inst.molecula_alvo = -1
	inst.molecula = mo_gerada.duplicate(true)
	inst.name = "molecula_render_result"
	resultView.add_child(inst)
	

##auxiliar####
##############
func pode_sintetizar() -> bool:
	if mo1_ok and mo2_ok:
		if mo1.id != mo2.id: return true
	return false


func _on_button_button_up() -> void:
	pan_alert.visible = false
	txt_alert.text = "------------"


func _on_but_salvar_button_up() -> void:
	MoleculasDb.registra_nova_molecula(mo_gerada)
	mo_gerada = {}
	for c in resultView.get_children():
		print(c.name)
		c.queue_free()
	but_salvar.disabled = true
