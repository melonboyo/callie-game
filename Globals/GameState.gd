extends Node


enum Upgrade {
	Jump1,
	Minecart
}

var upgrade_scenes := {
	Upgrade.Jump1: preload("res://Platforming/Upgrades/Jump1.tscn"),
	Upgrade.Minecart: preload("res://Platforming/Upgrades/Jump1.tscn"),
}


var acquired_upgrades = {
	Upgrade.Jump1: false,
	Upgrade.Minecart: false,
}

var opened_doors = {
	1: [
		false,
	],
	2: [
		false,
		false,
		false,
	]
}

var has_key = false

var exit = 0
var current_level = 1
var current_checkpoint = 0


func get_upgrade(ug: GameState.Upgrade):
	acquired_upgrades[ug] = true


func has_upgrade(ug: GameState.Upgrade) -> bool:
	return acquired_upgrades[ug]
