extends Node


enum Upgrade {
	Jump1
}

var upgrade_scenes := {
	Upgrade.Jump1: preload("res://Platforming/Upgrades/Jump1.tscn")
}

var acquired_upgrades = {
	Upgrade.Jump1: false
}

var has_key = false


func get_upgrade(ug: GameState.Upgrade):
	acquired_upgrades[ug] = true


func has_upgrade(ug: GameState.Upgrade) -> bool:
	return acquired_upgrades[ug]
