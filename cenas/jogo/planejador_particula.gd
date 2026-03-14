extends Control

@export var pan_add_par: PanelContainer
@export var pan_actions: PanelContainer
@export var pan_alerta: PanelContainer
@export var txt_alerta: Label
@export var area_particulas: Node2D
@export var area_matrix: Node2D
@export var lig_valor: OptionButton
@export var matrix_point: Area2D

var molecula = {
	"id":0,
	"particulas":[],
	"ligacoes":[]
}

var matrix2D = Vector2(8,5)
var matrixGrid = 100
var matrixOffset = Vector2(0,0)

#var par_alvo_lig =  {
#		"id":0,
#		"particula": 0,
#		"carga": 0,
#		"x_y":position
#	}

var par_alvo_lig :={}

var par_count_instance = 0

func _ready() -> void:
	monta_matrix()
	matrixOffset = matrix_point.position
	par_count_instance = 0

func monta_matrix() -> void:
	var index = 0
	for x in range(matrix2D.x):
		for y in range(matrix2D.y):
			if x==0 and y ==0:
				pass
			else:
				var p = matrix_point.duplicate()
				p.name = "drag_drop_pivot_%s"%[str(index)]
				p.position+= Vector2(x*matrixGrid,y*matrixGrid)
				area_matrix.add_child(p)
			index+=1
	

func add_particula(tipo:int,sinal:int) ->void:
	var parti = preload("res://cenas/planejador_modeculas/particula.tscn")
	var instance = parti.instantiate()
	instance.particula = tipo
	instance.carga = sinal
	instance.id = par_count_instance
	instance.position = Vector2(600,580)
	instance.connect("conectar",processa_conecao)
	instance.connect("deletar",processa_delete)
	instance.connect("drag",mostra_area_matrix)
	instance.connect("drop",esconde_area_matrix)
	instance.connect("drop_valid",mostra_pan_actions)
	area_particulas.add_child(instance)
	if sinal == 0:sinal = 1 # inverte sinal conflito no banco
	else: sinal = 0
	molecula.particulas.append({
		"tipo":tipo,
		"id":par_count_instance,
		"sinal":sinal,
		"x":0,
		"y":0
	})
	par_count_instance+=1
	pan_add_par.visible = false
	area_particulas.visible = true

func _on_but_fechar_add_par_button_up() -> void:
	pan_add_par.visible = false
	area_particulas.visible = true


func _on_but_fechar_pressed() -> void:
	self.queue_free()


func _on_but_add_par_button_up() -> void:
	pan_add_par.visible = true
	area_particulas.visible = false


func _on_but_c_button_up() -> void: # adicionar circulo negativo
	add_particula(0,1)
	pan_actions.visible = false

func _on_but_q_button_up() -> void:
	add_particula(1,1)
	pan_actions.visible = false


func _on_but_t_button_up() -> void:
	add_particula(2,1)
	pan_actions.visible = false


func _on_but_p_button_up() -> void:
	add_particula(3,1)
	pan_actions.visible = false


func _on_but_c_plu_button_up() -> void:
	add_particula(0,0)
	pan_actions.visible = false


func _on_but_q_plu_button_up() -> void:
	add_particula(1,0)
	pan_actions.visible = false


func _on_but_t_plu_button_up() -> void:
	add_particula(2,0)
	pan_actions.visible = false


func _on_but_p_plu_button_up() -> void:
	add_particula(3,0)
	pan_actions.visible = false

func mostra_area_matrix():
	area_matrix.visible = true
	
func esconde_area_matrix():
	area_matrix.visible = false
	
func mostra_pan_actions():
	molecula_normaliza_matrix()# aqui tem que fazer uma varredura na matrix das particulas na molecula
	pan_actions.visible = true

func processa_delete(context:Dictionary):
	area_matrix.visible = false
	pan_actions.visible = true
	for x in range(molecula.particulas.size()):
		if context.id == molecula.particulas[x].id:
			molecula.particulas.remove_at(x)
			break
	for x in range(molecula.ligacoes.size()):
		if molecula.ligacoes[x].particula == context.id or molecula.ligacoes[x].alvo == context.id:
			molecula.ligacoes.remove_at(x)
			break
	processa_exclusao_particula(context.x_y)

func processa_conecao(context:Dictionary):
	if pan_actions.visible == true:
		if par_alvo_lig.is_empty():
			par_alvo_lig = context
		else:
			criar_ligacoes(par_alvo_lig.x_y,context.x_y,lig_valor.selected+1)
			molecula.ligacoes.append({
				"particula":context.id,
				"alvo":par_alvo_lig.id,
				"valor":lig_valor.selected+1
			})
			par_alvo_lig = {}

func processa_exclusao_particula(ponto:Vector2):
	for x in area_particulas.get_children():
		if x is Line2D:
			for p in x.points:
				if p == ponto: 
					x.queue_free()
					break

func criar_ligacoes(point1:Vector2,point2:Vector2,valor:int=1):
	for x in range(valor):
		var linha = Line2D.new()
		linha.points = [point1,point2]
		#linha.name = nome
		linha.width = 6
		linha.default_color = Color(1, 1, 1)
		linha.z_index = 1
		if valor>1:
			linha.width = 3
			if abs(point1.x - point2.x) > 10 and abs(point1.y - point2.y) < 10:
				linha.position.y += (x*5)-5
			if abs(point1.y - point2.y) > 10 and abs(point1.x - point2.x) < 10:
				linha.position.x += (x*5)-5
			if abs(point1.x - point2.x) > 10 and abs(point1.y - point2.y) > 10:
				linha.position+= Vector2((x*5)-5,(x*5)-5)
		area_particulas.add_child(linha)

func molecula_normaliza_matrix():
	for p in area_particulas.get_children():
		if p is not Line2D:
			for par in molecula.particulas:
				if par.id == p.id:
					par.x = int((p.position.x-matrixOffset.x) / matrixGrid)
					par.x -= int(matrix2D.x/2)
					par.y = int((p.position.y-matrixOffset.y) / matrixGrid)
					par.y -= int(matrix2D.y/2)


func _on_but_salvar_button_up() -> void:
	var valido = MoleculaRules.molecula_valida(molecula)
	if valido:
		var banco = MoleculasDb.obter_todas_moleculas_do_banco()
		for item in banco:
			if MoleculaRules.molecula_is_equal(item,molecula) == true:
				txt_alerta.text = "Molecula Já Descoberta"
				pan_alerta.visible = true
				return
	else:
		txt_alerta.text = "Molecula Invalida, siga as regras, para montar uma Válida!"
		pan_alerta.visible = true
		return
	MoleculasDb.registra_nova_molecula(molecula)
	queue_free()


func _on_button_button_up() -> void:
	txt_alerta.text = ""
	pan_alerta.visible = false
