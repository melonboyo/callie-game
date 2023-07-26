extends Upgrade
class_name Boots

func pick_up():
	GameState.give_upgrade(GameState.Upgrade.Boots)
