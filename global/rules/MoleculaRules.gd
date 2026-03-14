extends Node

func molecula_valida(molecula:Dictionary) -> bool:
	var result :bool = true
	if molecula.particulas.size()<1 : return false
	if molecula.ligacoes.size()<1: return false
	# regra 1 uma molecula não pode ter particulas iguais de sinais diferentes
	for x in range(molecula.particulas.size()):
		for par in molecula.particulas:
			if molecula.particulas[x].tipo == par.tipo:
				if molecula.particulas[x].sinal != par.sinal:
					result = false
					
	# regra 2: particulas so fazem ligação com particulas de sinais opostos:
	for lig in molecula.ligacoes:
		if buscar_por_id(molecula.particulas,lig.particula).sinal == buscar_por_id(molecula.particulas,lig.alvo).sinal:
			result = false
			
	# regra 3: particulas devem completar todas as ligações necessárias por tipo
	# tipo 0 (circulo) = faz 1 
	# tipo 1 (quadrado) = faz 2
	# tipo 2 (triangulo) = faz 3
	# tipo 3 (pentagono) = faz 4
	for p in molecula.particulas:
		var bindCounter = 0
		for lig in molecula.ligacoes:
			if lig.particula == p.id:
				bindCounter+=lig.valor
			if lig.alvo == p.id:
				bindCounter+=lig.valor
		match p.tipo:
			0:
				if bindCounter != 1: result = false
			1:
				if bindCounter != 2: result = false
			2:
				if bindCounter != 3: result = false
			3:
				if bindCounter != 4: result = false
		
	return result 

func molecula_is_equal(mo1:Dictionary,mo2:Dictionary) -> bool:
	var result = true
	if mo1.particulas.size() != mo2.particulas.size(): result = false
	if mo1.ligacoes.size() != mo2.ligacoes.size(): result = false
	var par_tipo_counterA = [0,0,0,0,0,0,0,0]
	for par in mo1.particulas:
		par_tipo_counterA[(par.tipo)+(par.sinal*4)]+=1
	var par_tipo_counterB = [0,0,0,0,0,0,0,0]
	for par in mo2.particulas:
		par_tipo_counterB[(par.tipo)+(par.sinal*4)]+=1
	if par_tipo_counterA != par_tipo_counterB : result = false
	if par_tipo_counterA == [0,0,0,0,0,0,0,0]: result = false
	var ion_tipo_counterA : PackedInt32Array
	ion_tipo_counterA.resize(24)
	for lig in mo1.ligacoes:
		var parIndexA = buscar_por_id(mo1.particulas,lig.particula)
		var parIndexB = buscar_por_id(mo1.particulas,lig.alvo)
		ion_tipo_counterA[((parIndexA.tipo)+(parIndexA.sinal*4))*lig.valor]+=1
		ion_tipo_counterA[((parIndexB.tipo)+(parIndexB.sinal*4))*lig.valor]+=1
	var ion_tipo_counterB : PackedInt32Array
	ion_tipo_counterB.resize(24)
	for lig in mo2.ligacoes:
		var parIndexA = buscar_por_id(mo2.particulas,lig.particula)
		var parIndexB = buscar_por_id(mo2.particulas,lig.alvo)
		ion_tipo_counterB[((parIndexA.tipo)+(parIndexA.sinal*4))*lig.valor]+=1
		ion_tipo_counterB[((parIndexB.tipo)+(parIndexB.sinal*4))*lig.valor]+=1
	if ion_tipo_counterA != ion_tipo_counterB: result = false
	return result

func sintese(mole1:Dictionary,mole2:Dictionary) -> Dictionary:
	var mo_new = {"particulas":[],"ligacoes":[]}
	var mo1 = mole1.duplicate(true)
	var mo2 = mole2.duplicate(true)
	# fluxo 1: 
	#########: anular particulas de tipos iguais e sinais diferentes
	#########: e assim colocar o que restou em uma nova molecula:
	var recompose: Array=[]
	var parIndexAnulado: Array = []
	var par2IndexAnulado: Array = []
	var par1MaiorIndex = 0
	for par1 in mo1.particulas:
		for par2 in mo2.particulas:
			if par1.tipo == par2.tipo and par1.sinal != par2.sinal:
				if parIndexAnulado.find(par1.id)<0 and par2IndexAnulado.find(par2.id)<0:
					parIndexAnulado.append(par1.id)
					par2IndexAnulado.append(par2.id)
					break
		if par1.id > par1MaiorIndex: par1MaiorIndex= par1.id
	if parIndexAnulado.size()<1: return {}
	for x in parIndexAnulado:
		for par in range(mo1.particulas.size()):
			if mo1.particulas[par] != null:
				if mo1.particulas[par].id == x:
					mo1.particulas[par] = null
		mo1.particulas = mo1.particulas.filter(func(x): return x != null)
		for lig in range(mo1.ligacoes.size()):
			if mo1.ligacoes[lig].particula == x or mo1.ligacoes[lig].alvo == x:
				if mo1.ligacoes[lig].particula != x:
					if parIndexAnulado.find(mo1.ligacoes[lig].particula)<0:
						var nID = mo1.ligacoes[lig].particula
						recompose.append({
						"id":nID,
						"tipo":buscar_por_id(mo1.particulas,nID).tipo,
						"sinal":buscar_por_id(mo1.particulas,nID).sinal,
						"valor":mo1.ligacoes[lig].valor
					})
				elif mo1.ligacoes[lig].alvo != x:
					if parIndexAnulado.find(mo1.ligacoes[lig].alvo)<0:
						var nID = mo1.ligacoes[lig].alvo
						recompose.append({
						"id":nID,
						"tipo":buscar_por_id(mo1.particulas,nID).tipo,
						"sinal":buscar_por_id(mo1.particulas,nID).sinal,
						"valor":mo1.ligacoes[lig].valor
					})
				mo1.ligacoes[lig] = null
		mo1.ligacoes = mo1.ligacoes.filter(func(x): return x != null)
	for x in par2IndexAnulado:
		for par in range(mo2.particulas.size()):
			if mo2.particulas[par] != null:
				if mo2.particulas[par].id == x:
					mo2.particulas[par] = null
		mo2.particulas = mo2.particulas.filter(func(x): return x != null)
		for lig in range(mo2.ligacoes.size()):
			if mo2.ligacoes[lig].particula == x or mo2.ligacoes[lig].alvo == x:
				if mo2.ligacoes[lig].particula != x:
					if par2IndexAnulado.find(mo2.ligacoes[lig].particula)<0:
						var nID = mo2.ligacoes[lig].particula
						recompose.append({
						"id":nID + par1MaiorIndex+1,
						"tipo":buscar_por_id(mo2.particulas,nID).tipo,
						"sinal":buscar_por_id(mo2.particulas,nID).sinal,
						"valor":mo2.ligacoes[lig].valor
					})
				elif mo2.ligacoes[lig].alvo != x:
					if par2IndexAnulado.find(mo2.ligacoes[lig].alvo)<0:
						var nID = mo2.ligacoes[lig].alvo
						recompose.append({
						"id":nID + par1MaiorIndex+1,
						"tipo":buscar_por_id(mo2.particulas,nID).tipo,
						"sinal":buscar_por_id(mo2.particulas,nID).sinal,
						"valor":mo2.ligacoes[lig].valor
					})
				mo2.ligacoes[lig] = null
		mo2.ligacoes = mo2.ligacoes.filter(func(x): return x != null)
	mo_new = mo1.duplicate(true)
	for par in mo2.particulas:
		var parTemp = par
		par.id+=(par1MaiorIndex+1)
		mo_new.particulas.append(par)
	for lig in mo2.ligacoes:
		var ligTemp = lig
		ligTemp.particula+=(par1MaiorIndex+1)
		ligTemp.alvo+=par1MaiorIndex+1
		mo_new.ligacoes.append(ligTemp)
	
	#limpa relações de particulas e ligações que não são válidas:
	
		
	# Fluxo 2:  
	#########: agora é necessário refazer as ligações perdidas
	#########: no processo anterio, ou seja, dentar deixar a molecula
	#########: estavel novamente seguindo a prioridade das ordem da 
	#########: tabela recompose criada na anulação das particulas.
	for x in range(recompose.size()):
		for y in range(recompose.size()):
			if recompose[x] != null and recompose[y] != null:
				if recompose[x].id == recompose[y].id and x!=y:
					recompose[x].valor += recompose[y].valor
					recompose[y] = null
					break
	recompose = recompose.filter(func(x): return x != null)
	var countCicle = 0
	while recompose.size() > 1:
		for n in range(recompose.size()-1):
			if recompose[0].tipo != recompose[n+1].tipo:
				if recompose[0].sinal != recompose[n+1].sinal:
					var result = recompose[0].valor-recompose[n+1].valor
					var bindsHigh = recompose[0].valor
					var bindsLow = recompose[n+1].valor
					if result <= 0:
						mo_new.ligacoes.append({
							"particula":recompose[0].id,
							"alvo":recompose[n+1].id,
							"valor":recompose[0].valor,
						})
						recompose.remove_at(0)
						if result == 0 : recompose.remove_at(n)
						else: recompose[n].valor-= bindsHigh
						break
					else:
						mo_new.ligacoes.append({
							"particula":recompose[0].id,
							"alvo":recompose[n+1].id,
							"valor":bindsLow,
						})
						recompose[0].valor-=bindsLow
						recompose.remove_at(n+1)
						break
			
		countCicle+=1
		if countCicle > 100: break
		
	# fluxo 3:
	#########: reorganizar posição fisica das particulas na matrix
	
	if not molecula_valida(mo_new): return {}
	mo_new = reorganizar_molecula(mo_new)
	return mo_new

## auxiliar:
###########
func buscar_por_id(lista: Array, id_procurado):
	for item in lista:
		if item.get("id") == id_procurado:
			return item
	return null
	
func reorganizar_molecula(mol: Dictionary) -> Dictionary:
	var particulas = mol["particulas"]
	var ligacoes = mol["ligacoes"]

	var grau := {}
	var viz := {}
	var pos := {}
	var ocupado := {}

	# inicializar estruturas
	for p in particulas:
		grau[p.id] = 0
		viz[p.id] = []

	# calcular graus e vizinhos
	for l in ligacoes:
		grau[l.particula] += 1
		grau[l.alvo] += 1

		viz[l.particula].append(l.alvo)
		viz[l.alvo].append(l.particula)

	# encontrar núcleo
	var nucleo = null
	var maior = -1

	for id in grau:
		if grau[id] > maior:
			maior = grau[id]
			nucleo = id

	# direções possíveis
	var dirs = [
		Vector2i(1,0),
		Vector2i(-1,0),
		Vector2i(0,1),
		Vector2i(0,-1),
		Vector2i(1,1),
		Vector2i(-1,1),
		Vector2i(1,-1),
		Vector2i(-1,-1)
	]

	# iniciar BFS
	var fila := [nucleo]
	pos[nucleo] = Vector2i(0,0)
	ocupado[pos[nucleo]] = true

	while fila.size() > 0:

		var atual = fila.pop_front()

		var vizinhos = viz[atual].duplicate()

		# priorizar maior grau
		vizinhos.sort_custom(func(a,b):
			return grau[a] > grau[b]
		)

		for v in vizinhos:

			if pos.has(v):
				continue

			var base = pos[atual]
			var encontrado = false

			# procurar primeira posição livre
			for d in dirs:

				var tentativa = base + d

				if not ocupado.has(tentativa):
					pos[v] = tentativa
					ocupado[tentativa] = true
					encontrado = true
					break

			# fallback caso todas direções estejam ocupadas
			if not encontrado:
				var raio = 2
				while not encontrado:
					for d in dirs:
						var tentativa = base + d * raio
						if not ocupado.has(tentativa):
							pos[v] = tentativa
							ocupado[tentativa] = true
							encontrado = true
							break
					raio += 1

			fila.append(v)

	# aplicar posições
	for p in particulas:
		if pos.has(p.id):
			p.x = pos[p.id].x
			p.y = pos[p.id].y

	return mol
