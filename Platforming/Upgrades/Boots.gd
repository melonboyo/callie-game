extends Upgrade
class_name Boots

func pick_up():
	GameState.get_upgrade(GameState.Upgrade.Boots)
