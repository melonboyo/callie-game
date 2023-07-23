extends Upgrade
class_name Minecart


signal picked_up_minecart()


func pick_up():
	GameState.get_upgrade(GameState.Upgrade.Minecart)
	picked_up_minecart.emit()
