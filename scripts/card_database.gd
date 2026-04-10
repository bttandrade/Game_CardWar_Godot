const CARDS = {
	# HERÓIS
	"hero_soldier" :  [2, 2, "unit", "Um resistente soldado", "", 1],
	"hero_archer" :   [4, 2, "unit", "Um arqueiro habilidoso", "", 2],
	"hero_spear" :    [3, 3, "unit", "Um elfo mestre com a lança", "", 2],
	"hero_mage" :     [4, 4, "unit", "Um elfo mago poderoso", "", 3],
	"hero_duelist" :  [5, 3, "unit", "Um elfo mestre com a espada", "", 3],
	"hero_knight" :   [2, 6, "unit", "*Concede 2 de vida a todas as units aliadas", "res://scripts/abilities/formation.gd", 4],
	"hero_arrows":    [null, null, "magic", "*Causa 1 de dano a todas as units inimigas", "res://scripts/abilities/arrows.gd", 2],
	"hero_ballista":  [null, null, "magic", "*Causa 3 de dano diretamente ao oponente", "res://scripts/abilities/ballista.gd", 3],

	# VILÕES
	"villain_demon" :   [2, 2, "unit", "Um demonio comum", "", 1],
	"villain_soldier" : [2, 4, "unit", "Um esqueleto soldado", "", 2],
	"villain_archer" :  [4, 2, "unit", "Um esqueleto arqueiro", "", 2],
	"villain_pyro" :    [5, 3, "unit", "Um demonio piromante", "", 3],
	"villain_trident" : [3, 5, "unit", "Um demonio voador", "", 3],
	"villain_death" :   [2, 4, "unit", "*Destrói qualquer unit inimiga que atacar", "res://scripts/abilities/death_touch.gd", 4],
	"villain_decay":    [null, null, "magic", "*Reduz 2 de ataque de todas as units inimigas", "res://scripts/abilities/decay.gd", 2],
	"villain_hellfire": [null, null, "magic", "*Causa 4 de dano a uma unit inimiga", "res://scripts/abilities/hellfire.gd", 3],

	# PIRATAS
	"pirate_soldier" : [1, 3, "unit", "Um pirata comum", "", 1],
	"pirate_pistol" :  [4, 2, "unit", "Um pirata com pistolas", "", 2],
	"pirate_spear" :   [2, 4, "unit", "Um anão pirata arpoeiro", "", 2],
	"pirate_dual" :    [4, 4, "unit", "Um pirata mestre dos sabres", "", 3],
	"pirate_bomb" :    [5, 3, "unit", "Um pirata mestre dos explosivos", "", 3],
	"pirate_cannon" :  [2, 4, "unit", "*Ataca todas as units inimigas em campo", "res://scripts/abilities/cannon.gd", 4],
	"pirate_plunder":  [null, null, "magic", "*Rouba 1 moeda do oponente", "res://scripts/abilities/plunder.gd", 2],
	"pirate_cannonball": [null, null, "magic", "*Dispara 2 tiros aleatórios de 2 de dano cada", "res://scripts/abilities/cannonball.gd", 3],

	# ORCS
	"green_warrior" : [3, 1, "unit", "Um ogro guerreiro", "", 1],
	"green_sword" :   [4, 2, "unit", "Um goblin com espadão", "", 2],
	"green_mace" :    [3, 3, "unit", "Um ogro com maça de ferro", "", 2],
	"green_mage" :    [4, 4, "unit", "Um goblin bruxo", "", 3],
	"green_dual" :    [5, 3, "unit", "Um ogro com dois espadões", "", 3],
	"green_axe" :     [4, 4, "unit", "*Pode atacar duas vezes", "res://scripts/abilities/attack_twice.gd", 4],
	"green_warcry":   [null, null, "magic", "*Todas suas units ganham 1 de ataque", "res://scripts/abilities/warcry.gd", 2],
	"green_devastation": [null, null, "magic", "*Destrói a carta com menor vida em todo campo", "res://scripts/abilities/devastation.gd", 3]
}
