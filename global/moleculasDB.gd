# res://global/CartaDB.gd
extends Node

enum tipo{CIRCULO,QUADRADO,TRIANGULO,PENTAGONO}
enum sinal{P,N}

var molecula := {}

func _ready():
	# Aqui você registra as cartas com identificadores únicos
	
	registrar_molecula(0, {
		"id": 0,
		"particulas":[
			{"tipo":tipo.CIRCULO,"id":1,"sinal":sinal.P,"x":-1,"y":0},
			{"tipo":tipo.QUADRADO,"id":2,"sinal":sinal.N,"x":0,"y":0},
			{"tipo":tipo.CIRCULO,"id":3,"sinal":sinal.P,"x":1,"y":0},
		],
		"ligacoes":[
			{"particula":1,"alvo":2,"valor":1},
			{"particula":3,"alvo":2,"valor":1},
		]
	})
	


func registrar_molecula(id: int, dados: Dictionary):
	molecula[id] = dados

func registra_nova_molecula(dados:Dictionary):
	var mo = {
		"id":molecula.size()+1,
		"particulas":dados.particulas,
		"ligacoes":dados.ligacoes
	}
	registrar_molecula(molecula.size()+1,mo)

func obter_dados(id: int) -> Dictionary:
	return molecula.get(id, {})
	

func obter_todas_moleculas_do_banco() -> Array:
	var ret = []
	for mo in molecula.values():
		ret.append(mo)
	return ret
		

func carrega_banco(contex:Dictionary) ->void:
	molecula = {}
	for mo in contex.moleculas:
		registrar_molecula(int(mo),contex.moleculas[mo])
	normaliza_numeros()

func normaliza_numeros() -> void:
	for mo in molecula:
		if molecula[mo].id is not int: molecula[mo].id = int(molecula[mo].id)
		for par in molecula[mo].particulas:
			if par.tipo is not int: par.tipo = int(par.tipo)
			if par.id is not int: par.id = int(par.id)
			if par.sinal is not int:par.sinal = int(par.sinal)
			if par.x is not int:par.x = int(par.x)
			if par.y is not int:par.y = int(par.y)
		for lig in molecula[mo].ligacoes:
			if lig.particula is not int:lig.particula = int(lig.particula)
			if lig.alvo is not int: lig.alvo = int(lig.alvo)
			if lig.valor is not int: lig.valor = int(lig.valor)
