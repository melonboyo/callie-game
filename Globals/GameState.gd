extends Node


enum Upgrade {
	Jump1,
	Minecart,
	Boots,
}

var acquired_upgrades = {
	Upgrade.Jump1: false,
	Upgrade.Minecart: false,
	Upgrade.Boots: false,
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


func give_upgrade(upgrade: GameState.Upgrade):
	acquired_upgrades[upgrade] = true


func has_upgrade(upgrade: GameState.Upgrade) -> bool:
	return acquired_upgrades[upgrade]


signal opened_door(level: int, door_number: int)
func open_door(level: int, door_number: int, emit: bool = false):
	opened_doors[level][door_number] = true
	if emit: opened_door.emit(level, door_number)


var saved_properties = [
	"acquired_upgrades",
	"opened_doors",
	"exit",
]


func export():
	var state := {}
	
	for property in saved_properties:
		state[property] = get(property)
	
	return state


func import(state: Dictionary):
	for property in saved_properties:
		if state.has(property):
			set(property, state[property])
