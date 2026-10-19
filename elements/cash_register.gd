extends StaticBody3D

@export var required_scene: PackedScene 

var is_sold: bool = false

func interact(player: Node):
	if is_sold:
		print("Касса: Больше ничего не продаю.")
		return
		
	if player.held_item_scene == required_scene:
		print("Покупка прошла успешно!")
		player.clear_hands()
		is_sold = true
