const CARDS = {
	"hero_soldier" : [2, 4, "unit", "Um resistente soldado", ""],
	"hero_archer" : [4, 1, "unit", "Um arqueiro habilidoso", ""],
	"hero_mage" : [5, 2, "unit", "Um elfo mago poderoso", ""],
	"hero_knight" : [4, 7, "unit", "*Pode atacar duas vezes", "res://scripts/abilities/attack_twice.gd"],
	"hero_rain_of_arrows": [null, null, "magic", "*Causa 1 de dano a todas as cartas do oponente", "res://scripts/abilities/rain_of_arrows.gd"],
	"hero_balista_shot": [null, null, "magic", "*Causa 2 de dano diretamente ao oponente", "res://scripts/abilities/balista_shot.gd"],
	"hero_duelist" : [5, 2, "unit", "Um elfo mestre com a espada", ""],
	"hero_spear" : [5, 2, "unit", "Um elfo mestre com a lança", ""],
	"villain_demon" : [2, 4, "unit", "Um demonio comum", ""],
	"villain_soldier" : [4, 1, "unit", "Um esqueleto soldado", ""],
	"villain_pyro" : [5, 2, "unit", "Um demonio piromante", ""],
	"villain_death" : [4, 7, "unit", "*Pode atacar duas vezes", "res://scripts/abilities/attack_twice.gd"],
	"villain_decay": [null, null, "magic", "*Reduz 1 de ataque de todas as cartas do oponente", "res://scripts/abilities/decay.gd"],
	"villain_hellfire": [null, null, "magic", "*Causa 2 de dano a uma unit do oponente e causa 1 as adjacentes", "res://scripts/abilities/hellfire.gd"],
	"villain_trident" : [5, 2, "unit", "Um demonio voador", ""],
	"villain_archer" : [5, 2, "unit", "Um esqueleto arqueiro", ""]
}
