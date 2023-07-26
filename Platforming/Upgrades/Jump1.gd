extends Upgrade
class_name Jump1

func pick_up():
	GameState.give_upgrade(GameState.Upgrade.Jump1)
