class_name Constants

const PRIMARY_COLOR := Color.WHITE
const SECONDARY_COLOR := Color("8a8a8a")
const BACKGROUND_COLOR := Color.BLACK

enum Sound {
	JUMP = 0,
	STEP_GRASS = 1,
	STEP_CONCRETE = 2,
	STEP_WOOD = 3,
	CLIMB = 4,
	MINECART_GO = 5,
	MINECART_JUMP = 6,
	MINECART_EXIT = 7,
	MINECART_DRIVING = 8,
}

const character_scenes := [
	"res://Player/PlayerSprite1.tscn",
	"res://Player/PlayerSprite2.tscn",
]
