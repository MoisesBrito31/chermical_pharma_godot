extends Node2D

# =========================
# CONFIG
# =========================
const ESCALA := Vector2(1, 1)
const GRID := 100
var grid_offset := Vector2(1152/2,648/2)
const LARGURA_LINHA := 4
const OFFSET := 10

# =========================
# TEXTURAS
# =========================
var img_circulo = load("res://assets/formas/circulo.png")
var img_quadrado = load("res://assets/formas/quadrado.png")
var img_pentagono  = load("res://assets/formas/pentagono.png")
var img_triangulo  = load("res://assets/formas/triangulo.png")
var img_bond  = load("res://assets/formas/ligacao.png")

var font_bold = load("res://assets/fontes/No Safety Zone.ttf")

@onready var node_base = $Node2D

var molecula := {}
var molecula_alvo = 1

# ============================
#INIT - função que define qual molecula redenrizar
#============================

# =========================
# READY
# =========================
func _ready() -> void:
	var viewPort = get_viewport_rect().size
	grid_offset = Vector2(viewPort.x/2,viewPort.y/2)
	if molecula_alvo>=0:
		molecula = MoleculasDb.obter_dados(molecula_alvo)
	_criar_particulas()
	_criar_ligacoes()
	#viewport_dinamic_fit()
	#get_viewport().size_changed.connect(_on_resize)

# =========================
# PARTICULAS
# =========================
func _criar_particulas():
	for mo in molecula.particulas:
		var sp = Sprite2D.new()

		match mo.tipo:
			MoleculasDb.tipo.CIRCULO:
				sp.texture = img_circulo
			MoleculasDb.tipo.QUADRADO:
				sp.texture = img_quadrado
			MoleculasDb.tipo.TRIANGULO:
				sp.texture = img_triangulo
			MoleculasDb.tipo.PENTAGONO:
				sp.texture = img_pentagono
		var fator = max(molecula_densidade().x,molecula_densidade().y)
		var fatorGridOffset = max(grid_offset.x,grid_offset.y)/500
		sp.scale = ESCALA/fator*fatorGridOffset
		
		var posicoes_normalizadas = normalizar_posicoes(molecula.particulas)
		var posiX = posicoes_normalizadas[mo.id].x * (GRID/fator*5*fatorGridOffset)+grid_offset.x
		var posiY = posicoes_normalizadas[mo.id].y * (GRID/fator*5*fatorGridOffset)+grid_offset.y
		sp.position = Vector2(posiX,posiY)
		
		#adiciona o label de sinal
		var sinalLB = Label.new()
		sinalLB.add_theme_font_size_override("font_size",300)
		sinalLB.z_index = 2
		sinalLB.add_theme_color_override("font_color",Color(0,0,0,1))
		#sinalLB.add_theme_font_override("font",font_bold)
		sinalLB.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sinalLB.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		
		match mo.sinal:
			MoleculasDb.sinal.P:
				sinalLB.text = "+"
				sinalLB.position = Vector2(-80, -200)
				sp.modulate = Color(1, 0, 0)
			MoleculasDb.sinal.N:
				sinalLB.text = "-"
				sinalLB.position = Vector2(-50, -240)
				sp.modulate = Color(0, 0, 1)
		sp.add_child(sinalLB)
		sp.name = "M_%s" % [str(mo.id)]
		node_base.add_child(sp)

# =========================
# LIGACOES
# =========================
func _criar_ligacoes():
	var index = -1

	for lig in molecula.ligacoes:
		index += 1

		var posicoes = _buscar_posicoes(lig)
		var particula1V = posicoes[0]
		var particula2V = posicoes[1]

		if lig.valor == 1:
			var linha = _criar_linha_base("linha_" + str(index))
			linha.points = [particula1V, particula2V]
			node_base.add_child(linha)
		else:
			for x in range(int(lig.valor)):
				var linha = _criar_linha_base("linha_%s_%s" % [str(index), x])
				linha.points = [particula1V, particula2V]

				var lateralidade = 0

				if particula1V.x - particula2V.x == 0:
					linha.position.x += (x * OFFSET) - 5
				else:
					lateralidade += 1

				if particula1V.y - particula2V.y == 0:
					linha.position.y += (x * OFFSET) - 5
				else:
					lateralidade += 1

				if lateralidade >= 2:
					linha.position.x += (x * 14) - 7

				node_base.add_child(linha)

# =========================
# HELPERS
# =========================
func _criar_linha_base(nome):
	var linha = Line2D.new()
	linha.name = nome
	linha.width = LARGURA_LINHA
	linha.default_color = Color(1, 1, 1)
	linha.z_index = -1
	return linha

func _on_resize() -> void:
	pass
	#viewport_dinamic_fit()

func viewport_dinamic_fit()->void:
	var viewport_size = get_viewport_rect().size
	var base_size = Vector2(1152,648)
	
	if base_size.x == 0 or base_size.y==0: return
	
	var scale_fator = min(
		viewport_size.x / base_size.x,
		viewport_size.y / base_size.y
	)
	node_base.scale = Vector2(scale_fator,scale_fator)

func has_property(node: Object, prop_name: String) -> bool:
	for p in node.get_property_list():
		if p.name == prop_name:
			return true
	return false

func molecula_densidade() -> Vector2:
	var calc = Vector2(3,1)
	var xmin = 0
	var xmax = 0
	var ymin = 0
	var ymax = 0
	
	for par in molecula.particulas:
		if xmin > par.x: xmin = par.x
		if xmax < par.x: xmax = par.x
		if ymin > par.y: ymin = par.y
		if ymax < par.y: ymax = par.y
	calc = Vector2(xmax-xmin,ymax-ymin)
	
	return calc

func normalizar_posicoes(particulas:Array) -> Dictionary:
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	for p in particulas:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
	
	var centro = Vector2(
		(min_x + max_x) / 2.0,
		(min_y + max_y) / 2.0
	)
	
	var resultado := {}
	
	for p in particulas:
		resultado[p.id] = Vector2(
			p.x - centro.x,
			p.y - centro.y
		)
	
	return resultado

func _buscar_posicoes(lig):
	var particula1V = Vector2(0, 0)
	var particula2V = Vector2(0, 0)

	var nodes = node_base.get_children()

	for no in nodes:
		if no.name == "M_%s" % [str(lig.particula)]:
			particula1V = Vector2(no.position.x, no.position.y)

		if no.name == "M_%s" % [str(lig.alvo)]:
			particula2V = Vector2(no.position.x, no.position.y)

	return [particula1V, particula2V]
